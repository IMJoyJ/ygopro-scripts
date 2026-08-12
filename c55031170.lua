--K9－66b号 ランタン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在手卡存在的场合，以炎族以外的自己墓地1只5星「K9」怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。
-- ③：自己主要阶段才能发动。从卡组把1张「K9」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤(K9-66b号 灯鬼)"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡存在的场合，以炎族以外的自己墓地1只5星「K9」怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从卡组把1张「K9」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 不用解放召唤的条件判断函数
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否是不需要解放的召唤、自身等级在5星以上，且己方怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方手卡是否存在2张以上的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- 过滤自己墓地中炎族以外的5星「K9」怪兽且能特殊召唤的卡
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cb) and c:IsLevel(5) and not c:IsRace(RACE_PYRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标选择（Target）函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在至少1只满足条件的怪兽作为效果对象
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 特殊召唤效果的实际处理（Operation）函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 检查手卡的这张卡和墓地的对象怪兽是否仍对应连锁，且墓地怪兽不受王家之谷影响
	if c:IsRelateToChain() and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将手卡的这张卡和墓地的对象怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 遍历特殊召唤成功的怪兽组
			for sc in aux.Next(g) do
				-- 这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。③：自己主要阶段才能发动。从卡组把1张「K9」魔法·陷阱卡加入手卡。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetValue(s.xyzlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1,true)
				sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「K9-66b号 灯鬼」的效果特殊召唤"
			end
		end
	end
end
-- 限制不能作为光属性超量怪兽的超量素材
function s.xyzlimit(e,c)
	return c and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤卡组中「K9」魔法·陷阱卡且能加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动准备与可行性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「K9」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手卡的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「K9」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
