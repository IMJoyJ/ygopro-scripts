--レアメタル・ナイト
-- 效果：
-- 「稀有金属女郎」＋「稀有金属战士」
-- 这张卡在对怪兽的战斗伤害计算时，攻击力上升1000，在场上的这张卡可以和融合区的「稀有金属女武神」互换（这张卡特殊召唤的回合不可以互换。）
function c1412158.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为92421852和38916461的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,92421852,38916461,true,true)
	-- 这张卡在对怪兽的战斗伤害计算时，攻击力上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1412158,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1412158.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- 在场上的这张卡可以和融合区的「稀有金属女武神」互换（这张卡特殊召唤的回合不可以互换。）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1412158,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1412158.spcon)
	e2:SetTarget(c1412158.sptg)
	e2:SetOperation(c1412158.spop)
	c:RegisterEffect(e2)
end
-- 判断是否处于伤害步骤或伤害计算步骤
function c1412158.atkcon(e)
	-- 获取当前战斗的攻击怪兽
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取当前战斗的防守怪兽
	local a=Duel.GetAttacker()
	-- 判断是否处于伤害步骤或伤害计算步骤
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d~=nil
end
-- 判断是否为特殊召唤的回合
function c1412158.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡不是在当前回合特殊召唤的，则可以发动互换效果
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 过滤函数，用于判断额外卡组中是否存在符合条件的「稀有金属女武神」
function c1412158.spfilter(c,e,tp,mc)
	-- 判断卡号为75923050的卡是否可以特殊召唤且场上存在召唤空间
	return c:IsCode(75923050) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置连锁处理时的提示信息
function c1412158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查是否有满足条件的「稀有金属女武神」可以特殊召唤
		and Duel.IsExistingMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置将此卡送入额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置将「稀有金属女武神」特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作
function c1412158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 从额外卡组中检索符合条件的「稀有金属女武神」
		local tc=Duel.GetFirstMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
		-- 将此卡送入额外卡组并洗牌，若成功则继续特殊召唤
		if tc and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 将符合条件的「稀有金属女武神」特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
