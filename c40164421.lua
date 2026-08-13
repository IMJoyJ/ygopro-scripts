--ライトロード・メイデン ミネルバ
-- 效果：
-- ①：这张卡召唤时才能发动。把持有自己墓地的「光道」怪兽种类数量以下的等级的1只龙族·光属性怪兽从卡组加入手卡。
-- ②：这张卡从手卡·卡组送去墓地的场合发动。从自己卡组上面把1张卡送去墓地。
-- ③：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
function c40164421.initial_effect(c)
	-- ①：这张卡召唤时才能发动。把持有自己墓地的「光道」怪兽种类数量以下的等级的1只龙族·光属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40164421,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40164421.thtg)
	e1:SetOperation(c40164421.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合发动。从自己卡组上面把1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40164421,1))  --"送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c40164421.discon)
	e2:SetTarget(c40164421.distg)
	e2:SetOperation(c40164421.disop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40164421,2))  --"送墓"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c40164421.discon2)
	e3:SetTarget(c40164421.distg2)
	e3:SetOperation(c40164421.disop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡是否为「光道」怪兽（卡名含有0x38字段且为怪兽卡），用于筛选自己墓地的「光道」怪兽。
function c40164421.cfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 过滤函数：判断卡是否满足等级≤lv、龙族、光属性且能够加入手卡，用于筛选可检索的龙族·光属性怪兽。
function c40164421.thfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- ①效果的目标函数：在发动时先统计自己墓地「光道」怪兽的不同卡名数ct，检查卡组是否存在1只等级≤ct的龙族·光属性怪兽；若存在则设置本次连锁为从卡组将1张卡加入手卡。
function c40164421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己墓地的全部「光道」怪兽集合，用于统计种类数量。
		local g=Duel.GetMatchingGroup(c40164421.cfilter,tp,LOCATION_GRAVE,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		-- 检查卡组是否存在1张等级不超过ct（墓地「光道」怪兽种类数）且满足龙族·光属性、可加入手卡的怪兽，作为①效果能否发动的判定条件。
		return Duel.IsExistingMatchingCard(c40164421.thfilter,tp,LOCATION_DECK,0,1,nil,ct)
	end
	-- 设置操作信息：本次连锁把卡组中的1张卡加入手卡，供检索相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：重新统计墓地「光道」怪兽种类数ct，由玩家从卡组选择1只等级≤ct的龙族·光属性怪兽加入手卡，并向对方确认。
function c40164421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得自己墓地的「光道」怪兽集合，以计算最新的种类数ct。
	local g=Duel.GetMatchingGroup(c40164421.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 向当前玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组筛选并选择1张满足thfilter（等级≤ct、龙族、光属性、可加入手卡）的卡。
	local sg=Duel.SelectMatchingCard(tp,c40164421.thfilter,tp,LOCATION_DECK,0,1,1,nil,ct)
	if sg:GetCount()>0 then
		-- 将选择的卡以效果原因送去其持有者的手卡，完成检索加入手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）本次检索加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的条件函数：判定这张卡是从手卡或卡组被送去墓地，即满足“从手卡·卡组送去墓地的场合”这一诱发条件。
function c40164421.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- ②效果的目标函数：效果为必发，设置连锁的对象玩家为自己、要送墓的数量为1，并登记对应的卡组送墓操作信息。
function c40164421.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的对象玩家为效果控制者tp，即从谁的卡组送墓。
	Duel.SetTargetPlayer(tp)
	-- 设置本次连锁的对象参数为1，表示要送去墓地的卡牌数量。
	Duel.SetTargetParam(1)
	-- 设置操作信息：将玩家tp卡组最上方1张卡送去墓地，用于连锁判定及效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- ②效果的处理函数：取得连锁中记录的对象玩家和数量，将对应玩家卡组最上方指定数量的卡以效果原因送去墓地。
function c40164421.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和对象参数（玩家和送墓张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将对象玩家p的卡组最上方d张卡以效果原因送去墓地。
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
-- ③效果的条件函数：判定当前回合玩家是否为效果控制者，即只在自己的结束阶段发动。
function c40164421.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者tp，用于限定“自己结束阶段”这一时点。
	return tp==Duel.GetTurnPlayer()
end
-- ③效果的目标函数：效果为必发，设置操作信息为从自己卡组最上方把2张卡送去墓地。
function c40164421.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将玩家tp卡组最上方2张卡送去墓地，供后续效果处理与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- ③效果的处理函数：将自己卡组最上方2张卡以效果原因送去墓地。
function c40164421.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 执行将当前玩家tp的卡组最上方2张卡以效果原因送去墓地。
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
