--キラーチューン・ミクス
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把2星怪兽以外的1只「杀手级调整曲」怪兽加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册该卡效果：手卡调整作为同调素材的永续效果、召唤·特殊召唤时检索「杀手级调整曲」怪兽的诱发效果、作为同调素材送墓时破坏对方怪兽的诱发效果；①②效果各有1回合1次限制。
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把2星怪兽以外的1只「杀手级调整曲」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡作为同调素材送去墓地的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	s.killer_tune_be_material_effect=e4
end
-- 手卡同调素材的筛选条件：只允许调整怪兽作为手卡同调素材。
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 此效果仅在这张卡位于怪兽区域时适用，即必须是场上的这张卡作为同调素材的场合。
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 检索的过滤条件：满足「杀手级调整曲」怪兽、等级不为2、且能够加入手卡的怪兽。
function s.filter(c)
	return c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER) and not c:IsLevel(2)
		and c:IsAbleToHand()
end
-- ①效果发动条件与操作信息：从自己的卡组·墓地存在符合条件的「杀手级调整曲」怪兽；并设置将1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认在卡组·墓地是否存在至少1只符合s.filter条件的「杀手级调整曲」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本次效果处理为“加入手卡”，处理数量为1，处理位置为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从自己的卡组·墓地选择1只符合条件的「杀手级调整曲」怪兽加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择1张符合条件的「杀手级调整曲」怪兽；使用NecroValleyFilter以排除受到王家长眠之谷影响的墓地卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果发动条件：这张卡作为同调素材被送去墓地。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果的目标选择与操作信息：以对方场上1只怪兽为对象，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动时确认对方怪兽区域是否存在至少1只可选怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果处理为破坏，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与效果相关且为怪兽，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果破坏那只对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
