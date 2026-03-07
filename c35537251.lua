--BK シャドー
-- 效果：
-- 自己的主要阶段时才能发动。把自己场上的名字带有「燃烧拳击手」的超量怪兽1个超量素材取除，这张卡从手卡特殊召唤。「燃烧拳击手 假想敌拳手」的效果1回合只能使用1次。
function c35537251.initial_effect(c)
	-- 效果原文：自己的主要阶段时才能发动。把自己场上的名字带有「燃烧拳击手」的超量怪兽1个超量素材取除，这张卡从手卡特殊召唤。「燃烧拳击手 假想敌拳手」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35537251,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35537251)
	e1:SetTarget(c35537251.sptg)
	e1:SetOperation(c35537251.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤场上满足条件的超量怪兽（表侧表示、卡名含「燃烧拳击手」、类型为超量）
function c35537251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsType(TYPE_XYZ)
end
-- 效果作用：判断是否满足发动条件，包括是否有符合条件的超量素材、场上是否有空位以及此卡能否特殊召唤
function c35537251.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Group.CreateGroup()
		-- 效果作用：获取场上满足条件的超量怪兽组
		local mg=Duel.GetMatchingGroup(c35537251.cfilter,tp,LOCATION_MZONE,0,nil)
		local tc=mg:GetFirst()
		while tc do
			g:Merge(tc:GetOverlayGroup())
			tc=mg:GetNext()
		end
		if g:GetCount()==0 then return false end
		-- 效果作用：判断场上是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 效果作用：设置连锁处理信息，确定特殊召唤的目标为本卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：处理效果发动后的操作，包括检索符合条件的超量素材、选择并取除、将本卡特殊召唤
function c35537251.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 效果作用：获取场上满足条件的超量怪兽组
	local mg=Duel.GetMatchingGroup(c35537251.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=mg:GetFirst()
	while tc do
		g:Merge(tc:GetOverlayGroup())
		tc=mg:GetNext()
	end
	if g:GetCount()==0 then return end
	-- 效果作用：提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local sg=g:Select(tp,1,1,nil)
	-- 效果作用：将选择的超量素材送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果作用：将此卡从手卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
