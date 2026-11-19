--レアメタル・ナイト
-- 效果：
-- 「稀有金属女郎」＋「稀有金属战士」
-- 这张卡在对怪兽的战斗伤害计算时，攻击力上升1000，在场上的这张卡可以和融合区的「稀有金属女武神」互换（这张卡特殊召唤的回合不可以互换。）
function c1412158.initial_effect(c)
	-- 登记卡片文本中记述的关联卡名「稀有金属女武神」
	aux.AddCodeList(c,75923050)
	c:EnableReviveLimit()
	-- 注册融合召唤素材要求，需要「稀有金属女郎」和「稀有金属战士」各1只作为融合素材（可使用融合素材代替怪兽并能正规融合召唤）
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
-- 检查是否满足攻击力上升的适用条件：处于伤害步骤或伤害计算时，且自身正在对怪兽进行攻击
function c1412158.atkcon(e)
	-- 获取当前所处的决斗阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的目标怪兽
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d~=nil
end
-- 检查是否满足互换效果的发动条件：当前回合不是这张卡出场到场上的回合
function c1412158.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定这张卡转移到场上时的回合数与当前回合数是否不同
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 过滤额外卡组中可特殊召唤的「稀有金属女武神」：卡名为指定卡、能以该效果特殊召唤，且自身离场后有足够的额外卡组怪兽出场格位
function c1412158.spfilter(c,e,tp,mc)
	-- 检查卡片是否为「稀有金属女武神」、能否被特殊召唤，以及自身离开怪兽区后场上是否有供其从额外卡组特殊召唤的格子
	return c:IsCode(75923050) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动合法性检查：确认自身能返回额外卡组且额外卡组中存在可特殊召唤的「稀有金属女武神」
function c1412158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查自己额外卡组中是否存在至少1只满足条件的「稀有金属女武神」
		and Duel.IsExistingMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记本次连锁包含将自身1张卡返回卡组（额外卡组）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记本次连锁包含从自己额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行互换效果处理：确认自身仍在场上表侧表示时，将其返回额外卡组洗切并从额外卡组表侧表示特殊召唤「稀有金属女武神」
function c1412158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 从自己额外卡组中获取第一张符合条件的可特殊召唤的「稀有金属女武神」
		local tc=Duel.GetFirstMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
		-- 若存在该怪兽，则以效果将自身返回持有者额外卡组并确认成功离场
		if tc and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 将选定的「稀有金属女武神」以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
