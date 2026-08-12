--艮神鬼門 三千世界
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的里侧表示卡任意数量为对象才能发动。那些里侧表示卡数量的场地魔法卡以外的「艮神鬼」卡从卡组加入手卡（同名卡最多1张）。那之后，作为对象的里侧表示卡送去墓地。
-- ②：自己场上有「艮神鬼」怪兽以及里侧表示卡存在的状态，场上有卡被盖放的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：e1为永续魔陷/场地卡通用的允许发动的空效果（自由时点）；e2注册①效果（场地区起动、取对象、1回合1次的检索加送墓效果）；e3注册②效果（场地区、在魔陷盖放时触发的选发诱发效果）；e4/e5/e6克隆e3并分别改为怪兽盖放、表示形式变更、特殊召唤成功时触发，以覆盖「场上有卡被盖放」的各种时点。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上的里侧表示卡任意数量为对象才能发动。那些里侧表示卡数量的场地魔法卡以外的「艮神鬼」卡从卡组加入手卡（同名卡最多1张）。那之后，作为对象的里侧表示卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「艮神鬼」怪兽以及里侧表示卡存在的状态，场上有卡被盖放的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetCondition(s.thcon2)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.thcon2)
	c:RegisterEffect(e6)
end
-- ①效果检索对象的过滤器：「艮神鬼」系列（0x1e4）且不是场地魔法卡、可以加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1e4) and not c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- ①效果取对象目标的过滤器：里侧表示且可以送去墓地的卡。
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
-- ①效果的对象选择阶段：统计卡组中不同卡名的「艮神鬼」卡数量作为可选择对象数上限，发动条件要求卡组至少有1种可检索的卡且自己场上存在可作为对象的里侧表示卡；之后以自己场上1至ct张里侧表示卡为对象，并预登记送墓与从卡组加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 从卡组检索满足条件的「艮神鬼」卡（场地魔法卡除外），得到候选卡片组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 发动条件判定：卡组中不同卡名的可检索卡至少1种，且自己场上存在至少1张可作为对象的里侧表示卡。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示「请选择要送去墓地的卡」的选择信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 以自己场上1至ct张里侧表示卡为对象（ct为卡组中不同卡名的「艮神鬼」卡数量），作为之后要送去墓地的卡。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 预登记操作信息：作为对象的这些卡将被送去墓地，数量为对象卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 预登记操作信息：将从自己卡组把与对象数量相同张数的卡加入手卡（具体卡在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,g:GetCount(),tp,LOCATION_DECK)
end
-- ①效果的处理：重新取得卡组中可检索的「艮神鬼」卡，并筛选出本连锁对象中仍是里侧表示的卡；若对象卡数不超过卡组中不同卡名的种类数，则让玩家从中选出同名卡最多1张的相应数量卡加入手卡并给对方确认，之后把作为对象的里侧表示卡送去墓地。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新从卡组检索满足条件的「艮神鬼」卡（场地魔法卡除外），得到候选卡片组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 取得与本连锁相关的对象卡，并筛选出其中目前仍为里侧表示的卡。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsFacedown,nil)
	local sct=sg:GetCount()
	if sct>0 and g:GetClassCount(Card.GetCode)>=sct then
		-- 向玩家提示「请选择要加入手牌的卡」的选择信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从候选卡中选出sct张卡名互不相同的卡（同名卡最多1张），sct为作为对象的里侧表示卡数量。
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,sct,sct)
		if tg:GetCount()>0 then
			-- 把选出的卡从卡组加入手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 把加入手卡的卡给对方玩家确认。
			Duel.ConfirmCards(1-tp,tg)
			if tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
				-- 把作为对象的里侧表示卡送去墓地。
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
-- ②效果条件用的过滤器：自己怪兽区域表侧表示的「艮神鬼」怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e4)
end
-- ②效果（魔陷盖放时点）的发动条件：自己场上有表侧表示的「艮神鬼」怪兽存在，且自己场上有里侧表示卡存在。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己怪兽区域存在至少1只表侧表示的「艮神鬼」怪兽（排除本连锁涉及的事件卡eg）。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 确认自己场上存在至少1张里侧表示的卡（排除本连锁涉及的事件卡eg）。
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
end
-- ②效果（表示形式变更/特殊召唤成功时点）的发动条件：自己场上有表侧表示的「艮神鬼」怪兽和里侧表示卡存在，且本次事件中确实有卡被盖放（变为里侧表示）。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己怪兽区域存在至少1只表侧表示的「艮神鬼」怪兽（排除本连锁涉及的事件卡eg）。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 确认自己场上存在至少1张里侧表示的卡（排除本连锁涉及的事件卡eg）。
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
		and eg:IsExists(Card.IsFacedown,1,nil)
end
-- ②效果的对象选择阶段：发动条件要求双方场上存在至少1张可以回到手卡的可取对象卡；之后以场上1张可以回到手卡的卡为对象，并预登记回手卡的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动条件判定：双方场上存在至少1张可以回到手卡且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」的选择信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以场上1张可以回到手卡的卡为对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 预登记操作信息：作为对象的那1张卡将回到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：取得本连锁的对象卡，若该卡仍与本连锁相关且仍在场上，则将其回到持有者的手卡。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 把作为对象的那张卡回到持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
