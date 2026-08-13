--BK シャドー
-- 效果：
-- 自己的主要阶段时才能发动。把自己场上的名字带有「燃烧拳击手」的超量怪兽1个超量素材取除，这张卡从手卡特殊召唤。「燃烧拳击手 假想敌拳手」的效果1回合只能使用1次。
function c35537251.initial_effect(c)
	-- 自己的主要阶段时才能发动。把自己场上的名字带有「燃烧拳击手」的超量怪兽1个超量素材取除，这张卡从手卡特殊召唤。「燃烧拳击手 假想敌拳手」的效果1回合只能使用1次。
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
-- 过滤函数：判断怪兽是否为表侧表示、字段为「燃烧拳击手」的超量怪兽，用于检索自己场上可提供超量素材的怪兽。
function c35537251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsType(TYPE_XYZ)
end
-- 发动条件的判定与登记：检查自己场上是否存在满足条件的超量怪兽的超量素材，且自己场上是否有空位、这张卡能否被特殊召唤；条件满足则登记本次特殊召唤的操作信息。
function c35537251.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Group.CreateGroup()
		-- 获取自己场上所有满足cfilter条件（表侧表示且为「燃烧拳击手」超量怪兽）的怪兽集合。
		local mg=Duel.GetMatchingGroup(c35537251.cfilter,tp,LOCATION_MZONE,0,nil)
		local tc=mg:GetFirst()
		while tc do
			g:Merge(tc:GetOverlayGroup())
			tc=mg:GetNext()
		end
		if g:GetCount()==0 then return false end
		-- 检查自己场上是否还有可用的主要怪兽区空格，以确定能否进行特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 登记本次连锁的特殊召唤操作信息：要特殊召唤的对象为效果持有者（这张卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：重新获取自己场上符合条件的超量怪兽的所有超量素材，若没有素材则终止；让玩家选择1个素材送去墓地，随后将此卡特殊召唤。
function c35537251.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 效果处理时再次获取自己场上符合条件的「燃烧拳击手」超量怪兽集合，用于收集其持有的超量素材。
	local mg=Duel.GetMatchingGroup(c35537251.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=mg:GetFirst()
	while tc do
		g:Merge(tc:GetOverlayGroup())
		tc=mg:GetNext()
	end
	if g:GetCount()==0 then return end
	-- 向玩家发出选择提示，提示文字为“请选择要取除的超量素材”，用于后续选择1个超量素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local sg=g:Select(tp,1,1,nil)
	-- 将玩家选中的超量素材以效果原因（REASON_EFFECT）送去墓地，完成取除素材的操作。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的主要怪兽区，不无视召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
