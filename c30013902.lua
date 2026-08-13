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
	-- 设置效果②的发动代价：把墓地中的这张卡除外（作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30013902.sptg1)
	e2:SetOperation(c30013902.spop1)
	c:RegisterEffect(e2)
end
-- 定义植物族通常怪兽的筛选条件：类型为通常怪兽、种族为植物族、表侧表示。
function c30013902.spcfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsFaceup()
end
-- 效果①的发动条件：检查自己场上是否存在至少1只表侧表示的植物族通常怪兽。
function c30013902.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.IsExistingMatchingCard检查自己场上是否存在满足条件的植物族通常怪兽。
	return Duel.IsExistingMatchingCard(c30013902.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的合法性判定：手牌中的这张卡能够特殊召唤且自己场上存在可用区域。
function c30013902.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空闲的主要怪兽区域（用于特殊召唤这张卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明本效果将特殊召唤这张卡（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时：若这张卡仍与效果相关联，则将其特殊召唤到场上。
function c30013902.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其控制者（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②对象的选择条件：自己场上连接标记在2以下且处于连接状态的「圣天树」或「圣蔓」连接怪兽，并且额外卡组中有同名卡可特殊召唤。
function c30013902.tgfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x1158,0x2158) and c:IsLinkBelow(2) and c:IsLinkState()
		-- 确认额外卡组中存在与目标怪兽同卡名且可通过本效果特殊召唤的卡。
		and Duel.IsExistingMatchingCard(c30013902.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 定义额外卡组中候选卡的条件：与对象卡同名、能够被特殊召唤，且从额外卡组特殊召唤时出场区域足够。
function c30013902.spfilter(c,e,tp,code)
	-- 依次判断候选卡是否同名、是否可特殊召唤、是否有额外卡组出场空格。
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②发动时的目标选择处理：选择自己场上1只符合条件的连接怪兽作为对象，并设置操作信息；同时进行取对象检查和发动合法性检查。
function c30013902.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c30013902.tgfilter(chkc,e,tp) end
	-- 发动时检查场上是否存在可作为效果②对象的连接怪兽（通过Duel.IsExistingTarget进行取对象检查）。
	if chk==0 then return Duel.IsExistingTarget(c30013902.tgfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家显示选择效果对象的提示消息（HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的连接怪兽，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30013902.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表明本效果将从额外卡组特殊召唤1只怪兽；由于具体卡在效果处理时确定，目标为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理时：若对象怪兽仍与效果关联，从额外卡组选择其同名怪兽，将其效果无效并特殊召唤；最后给予自肃效果，直到回合结束不能特殊召唤植物族以外的怪兽。
function c30013902.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果②发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		-- 从额外卡组中筛选出与对象怪兽同名且满足可特殊召唤条件的候选卡组。
		local g=Duel.GetMatchingGroup(c30013902.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,code)
		if #g>0 then
			-- 向玩家显示选择要特殊召唤的卡的提示消息（HINTMSG_SPSUMMON）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 分步特殊召唤：尝试把选中的卡表侧表示特殊召唤，若成功则继续执行后续无效化处理。
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				-- 效果无效（对应“那1只同名怪兽效果无效特殊召唤”中的“效果无效”，使怪兽效果无效化）。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 效果无效（对应“那1只同名怪兽效果无效特殊召唤”中的“效果无效”，使效果发动本身无效化）。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			-- 完成特殊召唤操作，与SpecialSummonStep配合使用，使特殊召唤正式生效。
			Duel.SpecialSummonComplete()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30013902.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册为场地效果，影响该玩家（tp），持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的限制条件：被特殊召唤的怪兽不是植物族时禁止特殊召唤。
function c30013902.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
