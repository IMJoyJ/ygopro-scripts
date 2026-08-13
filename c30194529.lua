--星杯戦士ニンギルス
-- 效果：
-- 连接怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合发动。自己从卡组抽出这张卡所连接区的「星杯」怪兽的数量。
-- ②：1回合1次，自己主要阶段才能发动。选自己以及对方场上的卡各1张送去墓地。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c30194529.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只以上的连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK),2)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤成功的场合发动。自己从卡组抽出这张卡所连接区的「星杯」怪兽的数量。
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
-- ①效果的发动条件：判断这张卡是以连接召唤方式特殊召唤成功。
function c30194529.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索/计数时用到的「星杯」怪兽过滤条件：表侧表示且字段为0xfd（星杯）。
function c30194529.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfd)
end
-- ①效果的发动时处理：允许发动；计数这张卡所连接区的「星杯」怪兽数量；将抽卡玩家设为自己；并设置抽卡操作信息（预计抽gc张）。
function c30194529.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c30194529.drfilter,nil)
	-- 将当前连锁的对象玩家设置为tp（效果发动者），表示由该玩家抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：效果类别为抽卡（CATEGORY_DRAW），目标玩家为tp，预计抽卡数为gc；因处理时需重新计算，目标卡组不确定，故targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,gc)
end
-- ①效果处理：从连锁信息中取得对象玩家p，重新计算所连接区的「星杯」怪兽数量gc，若大于0则让p抽gc张卡。
function c30194529.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家（抽卡玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c30194529.drfilter,nil)
	if gc>0 then
		-- 让玩家p因该效果抽gc张卡。
		Duel.Draw(p,gc,REASON_EFFECT)
	end
end
-- ②效果的发动合法性判断：自己场上和对方场上都至少要有1张卡，才能各选1张送去墓地。
function c30194529.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有卡存在（用于选自己场上1张卡）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0
		-- 同时检查对方场上是否有卡存在；二者都满足时②效果才可发动。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 设置②效果的操作信息：将2张卡送去墓地，具体是哪2张在效果处理时选择，所以targets为nil、count为2。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,0)
end
-- ②效果处理：再次确认双方场上都有卡；分别从自己场上和对方场上各选1张卡，合并后送去墓地。
function c30194529.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次检查双方场上是否各有卡；若任意一方场上无卡则直接终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then return end
	-- 弹出选择提示，提示玩家选择一张要送去墓地的卡（用于选择自己场上的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张卡（无过滤条件），作为要送去墓地的自己场上的卡。
	local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 弹出选择提示，提示玩家选择一张要送去墓地的卡（用于选择对方场上的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方场上选择1张卡，作为要送去墓地的对方场上的卡。
	local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将选出的自己场上和对方场上的卡合并后，因效果一并送去墓地。
	Duel.SendtoGrave(g1,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡被送去墓地前位于场上，即从场上送去墓地。
function c30194529.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤的过滤条件：手卡中的「星杯」怪兽，且可以被效果特殊召唤。
function c30194529.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动合法性判断：自己场上主要怪兽区有空位，且手卡中存在1只可特殊召唤的「星杯」怪兽。
function c30194529.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在满足条件的「星杯」怪兽；二者都满足时③效果才可发动。
		and Duel.IsExistingMatchingCard(c30194529.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置③效果的操作信息：效果类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），从手牌特殊召唤1只怪兽，具体处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：再次确认有可用怪兽区；从手卡选择1只符合条件的「星杯」怪兽，以表侧表示特殊召唤到自己场上。
function c30194529.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用怪兽区，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择一张要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「星杯」怪兽，准备特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c30194529.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
