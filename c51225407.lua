--魔妖壊劫
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的「魔妖」怪兽种类×100。
-- ②：把自己场上的表侧表示的1只「魔妖」怪兽和这张卡送去墓地才能发动。自己从卡组抽1张。
-- ③：从自己墓地把这张卡和1只不死族怪兽除外，以自己墓地1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。
function c51225407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的「魔妖」怪兽种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c51225407.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。②：把自己场上的表侧表示的1只「魔妖」怪兽和这张卡送去墓地才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51225407,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,51225407)
	e4:SetCost(c51225407.drcost)
	e4:SetTarget(c51225407.drtg)
	e4:SetOperation(c51225407.drop)
	c:RegisterEffect(e4)
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。③：从自己墓地把这张卡和1只不死族怪兽除外，以自己墓地1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(51225407,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,51225407)
	e5:SetCost(c51225407.spcost)
	e5:SetTarget(c51225407.sptg)
	e5:SetOperation(c51225407.spop)
	c:RegisterEffect(e5)
end
-- 该过滤函数用于筛选卡名属于「魔妖」字段的怪兽卡，是统计墓地魔妖种类前的基础条件。
function c51225407.atkfilter(c)
	return c:IsSetCard(0x121) and c:IsType(TYPE_MONSTER)
end
-- 计算对方场上怪兽的攻击力下降值：统计自己墓地存在的「魔妖」怪兽种类数，乘以-100（负值表示下降）。
function c51225407.atkval(e,c)
	-- 获取自己墓地里所有满足atkfilter条件的「魔妖」怪兽，组成集合用于后续种类计数。
	local g=Duel.GetMatchingGroup(c51225407.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*-100
end
-- 筛选自己场上表侧表示、且可以作为代价送入墓地的「魔妖」怪兽，用于②的发动代价。
function c51225407.drfilter(c)
	return c:IsSetCard(0x121) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- ②代价检查：确认作为发动卡的这张卡本身能送去墓地，并且自己场上存在至少1只符合条件的表侧「魔妖」怪兽。
function c51225407.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost()
		-- 判断场上是否存在至少1只可作为代价的表侧「魔妖」怪兽，这是②能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c51225407.drfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给出选择提示，让玩家从可选的卡中指定要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1只满足drfilter的表侧「魔妖」怪兽，作为②的发动代价。
	local g=Duel.SelectMatchingCard(tp,c51225407.drfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(c)
	-- 将选中的「魔妖」怪兽和这张卡一起以代价方式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置②效果发动时的目标信息：对象玩家为自己、抽卡数量为1，并登记抽卡类操作信息。
function c51225407.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认当前玩家可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次抽卡效果的对象玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次抽卡效果的抽卡数量参数设为1。
	Duel.SetTargetParam(1)
	-- 登记连锁操作信息为抽卡（CATEGORY_DRAW），抽卡玩家为自己、抽1张，供其他卡效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②的效果处理：读取之前保存的抽卡玩家和数量，实际执行抽卡。
function c51225407.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和参数，即抽牌者和抽牌数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果（REASON_EFFECT）为原因，让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选可作为③追加代价从墓地除外的1只不死族怪兽，同时确保墓地还存在另一只可被特殊召唤的「魔妖」怪兽作为对象。
function c51225407.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 额外检查：在排除当前候选不死族怪兽后，墓地仍存在至少1只可作为特殊召唤对象的「魔妖」怪兽。
		and Duel.IsExistingTarget(c51225407.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 筛选可以作为③特殊召唤对象的「魔妖」怪兽，要求其满足特殊召唤的常规条件。
function c51225407.spfilter(c,e,tp)
	return c:IsSetCard(0x121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③代价条件检查：确认这张卡自身能从墓地除外，且墓地存在符合cfilter条件的不死族怪兽可作为追加代价。
function c51225407.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在至少1只满足条件的不死族怪兽，用于作为③的追加代价。
		and Duel.IsExistingMatchingCard(c51225407.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给出选择提示，让玩家从可选卡中指定要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足cfilter的不死族怪兽，作为③的追加代价。
	local g=Duel.SelectMatchingCard(tp,c51225407.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的不死族怪兽和这张卡以表侧表示除外，作为③的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③的目标选择处理：选择自己墓地1只「魔妖」怪兽作为特殊召唤的对象，并登记特殊召唤类操作信息。
function c51225407.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51225407.spfilter(chkc,e,tp) end
	-- 效果发动合法性检查：确认自己场上还有空余的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 给出选择提示，让玩家指定要特殊召唤的「魔妖」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter的「魔妖」怪兽，将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c51225407.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记连锁操作信息为特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为选中的「魔妖」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③的效果处理：确认对象仍与效果关联后，将那只「魔妖」怪兽特殊召唤。
function c51225407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
