--聖種の影芽
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有植物族通常怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，以连接状态而连接2以下的自己1只「圣天树」怪兽或者「圣蔓」怪兽为对象才能发动。从额外卡组把那1只同名怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
function c30013902.initial_effect(c)
	-- ①：自己场上有植物族通常怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30013902,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30013902)
	e1:SetCondition(c30013902.spcon)
	e1:SetTarget(c30013902.sptg)
	e1:SetOperation(c30013902.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以连接状态而连接2以下的自己1只「圣天树」怪兽或者「圣蔓」怪兽为对象才能发动。从额外卡组把那1只同名怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30013902,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30013903)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30013902.sptg1)
	e2:SetOperation(c30013902.spop1)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在正面表示的植物族通常怪兽
function c30013902.spcfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsFaceup()
end
-- 效果条件：自己场上有植物族通常怪兽存在
function c30013902.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只正面表示的植物族通常怪兽
	return Duel.IsExistingMatchingCard(c30013902.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标设定：检查是否能将此卡特殊召唤
function c30013902.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将此卡加入特殊召唤的处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤
function c30013902.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否能选择作为对象的连接怪兽
function c30013902.tgfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x1158,0x2158) and c:IsLinkBelow(2) and c:IsLinkState()
		-- 检查自己额外卡组是否存在与所选对象同名且可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c30013902.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于判断额外卡组中是否存在可特殊召唤的同名怪兽
function c30013902.spfilter(c,e,tp,code)
	-- 检查额外卡组中是否存在可特殊召唤的同名怪兽且有足够召唤空间
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果目标设定：选择一只连接2以下的「圣天树」或「圣蔓」连接怪兽
function c30013902.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c30013902.tgfilter(chkc,e,tp) end
	-- 检查自己场上是否存在符合条件的连接怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c30013902.tgfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只符合条件的连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c30013902.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：将额外卡组中的一只怪兽加入特殊召唤的处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组特殊召唤同名怪兽
function c30013902.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		-- 获取额外卡组中所有与对象怪兽同名且可特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(c30013902.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,code)
		if #g>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将所选怪兽以正面表示特殊召唤到场上
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				-- 使特殊召唤的怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 使特殊召唤的怪兽效果在回合结束时无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
	-- 直到回合结束时自己不是植物族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30013902.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制非植物族怪兽不能特殊召唤
function c30013902.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
