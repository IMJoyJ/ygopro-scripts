--薔薇占術師
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡解放才能发动。自己从卡组抽1张。
-- ②：把墓地的这张卡除外，以自己墓地1只植物族怪兽为对象才能发动。那只怪兽加入手卡。这个效果把原本等级是7星以上的植物族怪兽加入手卡的场合，可以再从卡组把1只植物族怪兽送去墓地。
function c2752099.initial_effect(c)
	-- 「这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把这张卡解放才能发动。自己从卡组抽1张。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2752099,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,2752099)
	e1:SetCost(c2752099.drcost)
	e1:SetTarget(c2752099.drtg)
	e1:SetOperation(c2752099.drop)
	c:RegisterEffect(e1)
	-- 「这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己墓地1只植物族怪兽为对象才能发动。那只怪兽加入手卡。这个效果把原本等级是7星以上的植物族怪兽加入手卡的场合，可以再从卡组把1只植物族怪兽送去墓地。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2752099,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2752099)
	-- 为②效果设置发动代价：把墓地中的这张卡除外，作为发动代价支付。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2752099.thtg)
	e2:SetOperation(c2752099.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：检查这张卡是否可解放；若可，则把这张卡解放作为发动代价。
function c2752099.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以“代价”方式解放这张卡（从场上送去墓地），不视为效果处理。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义①效果的发动条件与目标设定：检查能否抽1张卡；若能，则记录抽卡玩家与抽卡数，并登记抽卡操作信息。
function c2752099.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0阶段）：确认当前玩家tp可以抽1张卡，若不能则效果不可发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的“对象玩家”设为发动者tp，表示后续由tp执行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的“对象参数”设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记抽卡的操作信息：目标玩家为tp，数量为1，用于相关卡片对抽卡效果的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义①效果的处理函数：从连锁信息中取出玩家p和抽卡数d，并让p执行抽d张卡。
function c2752099.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出之前记录的“对象玩家”p和“参数”d，即抽卡者和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡，完成①效果的抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义②效果选对象的过滤条件：对象必须是植物族怪兽，并且可以被加入手卡。
function c2752099.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 定义追加效果中从卡组选卡送墓的过滤条件：该卡必须是植物族怪兽，并且可以被送去墓地。
function c2752099.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 定义②效果的发动条件与对象选择：检查自己墓地是否有符合条件的植物族怪兽；若有则让发动者选择1只作为对象，并登记回手牌操作信息。
function c2752099.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2752099.thfilter(chkc) end
	-- 效果发动合法性检查：确认自己墓地存在至少1只满足thfilter条件的植物族怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c2752099.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息，进入对象选择流程。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己墓地选择1只满足条件的植物族怪兽作为效果对象，同时将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c2752099.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记将对象卡加入手卡的操作信息，用于相关卡片的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义②效果的处理函数：先将对象植物族怪兽加入手卡；若其原本等级为7星以上，且卡组中存在可送墓的植物族怪兽，则询问玩家是否追加从卡组送墓1只。
function c2752099.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡（自己墓地的1只植物族怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 以效果原因将该对象卡加入其持有者的手卡（回收）。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	if tc:IsLocation(LOCATION_HAND) and tc:GetOriginalLevel()>=7
		-- 追加条件判断：卡组中是否存在至少1只满足tgfilter条件的植物族怪兽可供送入墓地。
		and Duel.IsExistingMatchingCard(c2752099.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问发动者是否追加从卡组把1只植物族怪兽送去墓地；选择“是”才继续执行后续送墓。
		and Duel.SelectYesNo(tp,aux.Stringid(2752099,2)) then  --"是否再从卡组把1只植物族怪兽送去墓地？"
		-- 中断当前效果处理，使后续追加送墓作为独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要送去墓地的卡”的提示信息，为选择卡组怪兽做准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让发动者从卡组选择1只满足条件的植物族怪兽，用于送去墓地。
		local tg=Duel.SelectMatchingCard(tp,c2752099.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 以效果原因将选择的植物族怪兽从卡组送去墓地，完成追加效果。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
