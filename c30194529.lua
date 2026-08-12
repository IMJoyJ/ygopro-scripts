--星杯戦士ニンギルス
-- 效果：
-- 连接怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合发动。自己从卡组抽出这张卡所连接区的「星杯」怪兽的数量。
-- ②：1回合1次，自己主要阶段才能发动。选自己以及对方场上的卡各1张送去墓地。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c30194529.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2个连接素材，且这些素材必须是连接怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK),2)
	-- ①：这张卡连接召唤成功的场合发动。自己从卡组抽出这张卡所连接区的「星杯」怪兽的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30194529,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,30194529)
	e1:SetCondition(c30194529.drcon)
	e1:SetTarget(c30194529.drtg)
	e1:SetOperation(c30194529.drop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。选自己以及对方场上的卡各1张送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30194529,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c30194529.tgtg)
	e2:SetOperation(c30194529.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30194529,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c30194529.spcon2)
	e3:SetTarget(c30194529.sptg2)
	e3:SetOperation(c30194529.spop2)
	c:RegisterEffect(e3)
end
-- 效果发动的条件：确认此卡是以连接召唤方式特殊召唤成功的。
function c30194529.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：用于筛选场上正面表示的「星杯」怪兽。
function c30194529.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfd)
end
-- 设置效果的目标玩家和抽卡数量，用于后续抽卡效果处理。
function c30194529.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c30194529.drfilter,nil)
	-- 设置效果的目标玩家为当前处理效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息为抽卡效果，抽卡数量为连接区「星杯」怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,gc)
end
-- 效果处理函数：根据连接区「星杯」怪兽数量，向目标玩家抽相应数量的卡。
function c30194529.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c30194529.drfilter,nil)
	if gc>0 then
		-- 执行抽卡操作，抽卡数量为连接区「星杯」怪兽数量。
		Duel.Draw(p,gc,REASON_EFFECT)
	end
end
-- 设置效果的发动条件：确认己方场上存在至少1张卡，对方场上也存在至少1张卡。
function c30194529.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在至少1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0
		-- 检查对方场上是否存在至少1张卡。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 设置效果操作信息为送去墓地效果，选择2张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,0)
end
-- 效果处理函数：选择己方和对方各1张卡送去墓地。
function c30194529.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方和对方场上是否都存在卡，若无则不发动效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择己方场上的1张卡。
	local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上的1张卡。
	local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将选择的卡送去墓地。
	Duel.SendtoGrave(g1,REASON_EFFECT)
end
-- 效果发动的条件：确认此卡是从场上送去墓地的。
function c30194529.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：筛选手卡中可特殊召唤的「星杯」怪兽。
function c30194529.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标：确认己方场上存在空位且手卡中有「星杯」怪兽可特殊召唤。
function c30194529.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的「星杯」怪兽。
		and Duel.IsExistingMatchingCard(c30194529.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果操作信息为特殊召唤效果，特殊召唤1只「星杯」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：从手卡选择1只「星杯」怪兽特殊召唤。
function c30194529.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在空位，若无则不发动效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的「星杯」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30194529.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
