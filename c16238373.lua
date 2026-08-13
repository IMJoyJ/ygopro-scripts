--大電脳兵廠
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只念动力族怪兽为对象，支付那个等级×200基本分才能发动。比那只怪兽等级高并持有相同属性的1只机械族怪兽从卡组加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的念动力族怪兽和机械族怪兽各1只为对象才能发动。那之内的1只回到卡组最下面，另1只加入手卡。
local s,id,o=GetID()
-- 创建并注册两个效果：e1对应①的魔法卡发动效果（取对象、检索机械族），e2对应②的墓地起动效果（除外自身、回收除外区怪兽）
function s.initial_effect(c)
	-- ①：以自己场上1只念动力族怪兽为对象，支付那个等级×200基本分才能发动。比那只怪兽等级高并持有相同属性的1只机械族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的念动力族怪兽和机械族怪兽各1只为对象才能发动。那之内的1只回到卡组最下面，另1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收除外的卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果只能在这张卡不是本回合被送去墓地的情况下发动，满足“这个回合没有送去墓地”的发动条件
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（aux.bfgcost为通用的将自身除外作为cost的函数）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的cost函数，这里仅作标记（e:SetLabel(100)），实际LP支付延迟到target函数选择对象后再进行
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 定义对象过滤函数：筛选自己场上表侧表示、念动力族、且玩家能支付其等级×200LP、并且卡组存在可检索的机械族怪兽的怪兽
function s.cfilter(c,tp)
	-- 检查候选对象是否为表侧表示、念动力族，且玩家能够支付该怪兽等级×200的基本分
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and Duel.CheckLPCost(tp,c:GetLevel()*200)
		-- 同时检查卡组中是否存在满足检索条件的机械族怪兽（等级高于该对象、属性相同、可加入手卡），确保效果不是空发
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetAttribute())
end
-- 定义检索过滤条件：机械族怪兽，与对象属性相同（属性标志按位与非0），等级高于对象等级，且可以加入手卡
function s.thfilter(c,lv,att)
	return c:IsRace(RACE_MACHINE) and bit.band(c:GetAttribute(),att)~=0 and c:GetLevel()>lv and c:IsAbleToHand()
end
-- ①效果的目标选择函数：核对对象合法性，选择自己场上1只念动力族怪兽，支付对应LP，并登记检索操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足s.cfilter条件的念动力族怪兽可以作为效果对象
		return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- 向玩家显示“请选择效果的对象”的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的念动力族怪兽作为效果对象（同时登记为连锁对象）
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 支付所选怪兽等级×200的基本分，作为效果的发动代价
	Duel.PayLPCost(tp,tc:GetLevel()*200)
	-- 登记操作信息：本次效果将把1张卡从卡组加入手卡（用于效果发动后的时点检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理函数：若对象仍然相关且表侧，则从卡组选择符合条件的机械族怪兽加入手卡，并让对方确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时保存的对象（被选择的念动力族怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向玩家显示“请选择要加入手牌的卡”的选卡提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1只满足s.thfilter条件的机械族怪兽（等级高于对象、属性相同、可加入手卡）
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel(),tc:GetAttribute())
		if g:GetCount()>0 then
			-- 将选出的机械族怪兽加入手卡，原因为效果
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的那张机械族怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义②效果对象的过滤条件：除外区表侧表示的怪兽，可作为效果对象，能回卡组或加入手卡，且种族为机械族或念动力族
function s.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsAbleToHand(e,0,tp))
		and c:IsRace(RACE_MACHINE+RACE_PSYCHO)
end
-- 定义②效果选择2张对象时的组合过滤：需包含机械族和念动力族各至少1只，且至少1张能回卡组、至少1张能加入手卡
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,1,nil) and g:IsExists(Card.IsAbleToHand,1,nil)
		and g:IsExists(Card.IsRace,1,nil,RACE_MACHINE) and g:IsExists(Card.IsRace,1,nil,RACE_PSYCHO)
end
-- ②效果的目标选择函数：从除外区筛选符合条件的2张怪兽作为对象，登记回卡组和加入手卡各1张的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得自己除外区中所有满足s.tdfilter条件的怪兽组（机械族或念动力族、可作为对象）
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chkc then return false end
	if chk==0 then return dg:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 向玩家显示“请选择要操作的卡”的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选中的2张除外怪兽设置为当前连锁的对象，供处理时使用
	Duel.SetTargetCard(g)
	-- 登记操作信息：效果将把对象中的1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：效果将把对象中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理时选择“回卡组”的卡的过滤条件：能够返回卡组
function s.thfilter2(c,e,tp)
	return c:IsAbleToDeck()
end
-- ②效果处理函数：从对象中选择1张能回卡组的卡放到卡组最下面，另一张加入手卡，并让对方确认
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象组，并过滤出仍然与效果相关的卡（RelateToEffect）
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 向玩家显示“请选择要返回卡组的卡”的选卡提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:FilterSelect(tp,s.thfilter2,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 为选择要回卡组的卡显示取对象动画，并记录该卡被选择
			Duel.HintSelection(sg)
			-- 将选中的1张卡放置到其持有者卡组的最下面
			aux.PlaceCardsOnDeckBottom(tp,sg)
			tg:Sub(sg)
			if sg:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) and tg:GetCount()>0 and tg:GetFirst():IsAbleToHand() then
				-- 将剩余的那张对象卡加入手卡，原因为效果
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 让对方玩家确认加入手卡的那张卡
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
