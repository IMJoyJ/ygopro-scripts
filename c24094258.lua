--ヘビーメタルフォーゼ・エレクトラム
-- 效果：
-- 灵摆怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只灵摆怪兽表侧加入额外卡组。
-- ②：1回合1次，以自己场上1张其他的表侧表示卡为对象才能发动。那张卡破坏。那之后，从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
-- ③：自己的灵摆区域的卡从场上离开的场合发动。自己抽1张。
function c24094258.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡设置连接召唤手续：需要且仅需要2只灵摆怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2)
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24094258,0))  --"卡组灵摆怪兽加入额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c24094258.tecon)
	e1:SetTarget(c24094258.tetg)
	e1:SetOperation(c24094258.teop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1张其他的表侧表示卡为对象才能发动。那张卡破坏。那之后，从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24094258,1))  --"破坏并从额外卡组把灵摆怪兽加入手卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c24094258.destg)
	e2:SetOperation(c24094258.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己的灵摆区域的卡从场上离开的场合发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24094258,2))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,24094258)
	e3:SetCondition(c24094258.drcon)
	e3:SetTarget(c24094258.drtg)
	e3:SetOperation(c24094258.drop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判断：这张卡是否以连接召唤方式特殊召唤成功。
function c24094258.tecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义检索/选择灵摆怪兽的过滤函数：卡片为灵摆怪兽。
function c24094258.tefilter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 效果①的目标流程：若卡组存在至少1只灵摆怪兽则允许发动，并预置将1张卡从卡组表侧加入额外卡组的操作信息。
function c24094258.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（chk==0）：确认卡组中是否存在至少1只灵摆怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24094258.tefilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果将把1张卡从持有者卡组以表侧表示加入额外卡组（CATEGORY_TOEXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：玩家从卡组选择1只灵摆怪兽，并以表侧表示加入额外卡组。
function c24094258.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：要求玩家选择要表侧表示加入额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(24094258,3))  --"请选择要表侧表示加入额外卡组的卡"
	-- 让玩家从卡组中筛选出1只灵摆怪兽（自动选择符合条件的卡片）。
	local g=Duel.SelectMatchingCard(tp,c24094258.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽以表侧表示送入持有者的额外卡组（REASON_EFFECT）。
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
-- 定义②中从额外卡组选择灵摆怪兽加入手卡的过滤函数：表侧表示、灵摆怪兽且可以加入手卡。
function c24094258.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果②的发动条件与取对象：需要场上存在可被破坏的本方其他表侧表示卡（且额外卡组存在可加入手卡的灵摆怪兽）。
function c24094258.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=c end
	-- 检查场上是否存在满足条件的对象（己方场上除本卡以外表侧表示的卡）可作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c)
		-- 同时检查额外卡组（表侧）是否存在至少1只满足条件的灵摆怪兽可加入手卡，否则效果无法发动。
		and Duel.IsExistingMatchingCard(c24094258.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 显示破坏对象选择提示：请玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从自己场上表侧表示的卡中选择1张除本卡以外的卡作为对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置破坏类操作信息：将破坏上述选择的对象卡（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置回手类操作信息：效果将把额外卡组（表侧）的1只灵摆怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：将对象破坏（成功后才处理后续），然后从额外卡组（表侧）选1只灵摆怪兽加入手卡并给对手确认。
function c24094258.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（已取对象）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，且已被效果成功破坏，才继续执行加入手卡的部分。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 显示加入手卡的选择提示：要求玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从自己的额外卡组（表侧表示）选择1只满足条件的灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c24094258.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续加入手卡与之前的破坏处理视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 将选中的灵摆怪兽加入持有者的手卡（此处为玩家tp的手卡）。
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义③的离场过滤条件：卡片此前在灵摆区域且此前的控制者为玩家tp。
function c24094258.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
-- 效果③的发动条件：本次离场事件中存在符合条件（我方灵摆区域离场）的卡。
function c24094258.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24094258.drcfilter,1,nil,tp)
end
-- 效果③的目标设定：效果必定可发动，设置对象玩家为tp、抽卡数1，并预置抽卡操作信息。
function c24094258.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的对象玩家为效果发动者tp，指定谁将抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置本连锁的对象参数为1，即抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置抽卡操作信息：将让玩家tp抽取1张卡（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的处理：根据设置好的对象玩家和抽卡数量执行抽卡。
function c24094258.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中预置的对象玩家和对象参数（即抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽取指定数量的卡（此处为自己抽1张）。
	Duel.Draw(p,d,REASON_EFFECT)
end
