--ワイトロード
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：自己墓地有「白骨」或「白骨王」存在的场合，把手卡·场上的这张卡送去墓地才能发动。把最多有自己墓地的「白骨」「白骨王」数量的卡从自己卡组上面送去墓地。
-- ③：把墓地的这张卡除外，以自己墓地1只「白骨」或「白骨王」为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别为②和③效果
function s.initial_effect(c)
	-- 使该卡在墓地时视为「白骨」卡
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- ②：自己墓地有「白骨」或「白骨王」存在的场合，把手卡·场上的这张卡送去墓地才能发动。把最多有自己墓地的「白骨」「白骨王」数量的卡从自己卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ③：把墓地的这张卡除外，以自己墓地1只「白骨」或「白骨王」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果③的发动需要将此卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：自己墓地存在「白骨」或「白骨王」
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在「白骨」或「白骨王」
	return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果②的发动代价：将此卡送去墓地
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数，用于判断是否为「白骨」或「白骨王」
function s.tgfilter(c)
	return c:IsCode(32274490,36021814)
end
-- 效果②的发动时点处理，设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否至少有1张卡且可以将卡组最上端1张卡送去墓地
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息，表示将从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
end
-- 效果②的发动处理，选择从卡组送去墓地的卡数量并执行
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算最多可以送去墓地的卡数量
	local max=math.min(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0),Duel.GetMatchingGroupCount(s.tgfilter,tp,LOCATION_GRAVE,0,nil))
	if max==0 then return end
	local t={}
	for i=1,max do
		t[i]=max-i+1
	end
	-- 提示玩家选择要送去墓地的卡数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要送去墓地的卡的数量"
	-- 玩家宣言要送去墓地的卡数量
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 将宣言数量的卡从卡组最上端送去墓地
	Duel.DiscardDeck(tp,announce,REASON_EFFECT)
end
-- 过滤函数，用于判断是否为「白骨」或「白骨王」且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(32274490,36021814) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动时点处理，设置选择目标和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	-- 检查自己场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「白骨」或「白骨王」
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的发动处理，将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
