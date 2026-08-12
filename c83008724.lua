--おすすめ軍貫握り
-- 效果：
-- ①：1回合1次，把手卡1只「舍利军贯」给对方观看才能发动。给这张卡放置1个指示物，额外卡组1只「军贯」超量怪兽给对方观看，对方宣言1个在「军贯」超量怪兽有卡名记述的除「舍利军贯」以外的「军贯」怪兽的卡名。自己把对方宣言的卡从卡组加入手卡。不能加入的场合，这张卡回到持有者卡组。
-- ②：这张卡被对方破坏的场合发动。对方支付这张卡放置的指示物数量×500基本分。
local s,id,o=GetID()
-- 初始化效果：注册卡片效果（允许放置指示物、初始化军贯相关卡名表、注册发动效果、起动效果、离场前记录指示物数量的辅助效果、被破坏时让对方支付生命值的诱发效果）。
function s.initial_effect(c)
	c:EnableCounterPermit(0x66)
	-- 初始化「军贯」超量怪兽有卡名记述的除「舍利军贯」以外的「军贯」怪兽卡名列表（包含：白鱼军贯、海胆军贯、鱼子军贯）。
	aux.SushipMentionsTable=aux.SushipMentionsTable or {61027400,78362751,42377643}
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把手卡1只「舍利军贯」给对方观看才能发动。给这张卡放置1个指示物，额外卡组1只「军贯」超量怪兽给对方观看，对方宣言1个在「军贯」超量怪兽有卡名记述的除「舍利军贯」以外的「军贯」怪兽的卡名。自己把对方宣言的卡从卡组加入手卡。不能加入的场合，这张卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏的场合发动。对方支付这张卡放置的指示物数量×500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡被对方破坏的场合发动。对方支付这张卡放置的指示物数量×500基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.plpcon)
	e4:SetOperation(s.plpop)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
-- 过滤条件：手卡中未给对方观看的「舍利军贯」
function s.cfilter(c)
	return c:IsCode(24639891) and not c:IsPublic()
end
-- ①效果的发动代价：把手卡1只「舍利军贯」给对方观看
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在未给对方观看的「舍利军贯」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡1只「舍利军贯」
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的「舍利军贯」
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
end
-- 过滤条件：额外卡组中未给对方观看的「军贯」超量怪兽
function s.rfilter(c)
	return c:IsSetCard(0x166) and c:IsType(TYPE_XYZ) and not c:IsPublic()
end
-- ①效果的发动准备：检查额外卡组是否存在可观看的「军贯」超量怪兽，并设置放置指示物的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在未给对方观看的「军贯」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：给这张卡放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler(),1,tp,0x66)
end
-- 过滤条件：卡组中卡名与宣言卡名相同且能加入手牌的卡
function s.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- ①效果的效果处理：给这张卡放置1个指示物，额外卡组1只「军贯」超量怪兽给对方观看，对方宣言1个在「军贯」超量怪兽有卡名记述的除「舍利军贯」以外的「军贯」怪兽的卡名。自己把对方宣言的卡从卡组加入手卡。不能加入的场合，这张卡回到持有者卡组。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:AddCounter(0x66,1) then return end
	-- 提示玩家选择要给对方确认的额外卡组卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组1只「军贯」超量怪兽
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g==0 then return end
	-- 给对方玩家确认选择的「军贯」超量怪兽
	Duel.ConfirmCards(1-tp,g)
	local nt={}
	-- 遍历除「舍利军贯」以外的「军贯」怪兽卡名列表，构建用于宣言卡名的过滤器
	for i,n in ipairs(aux.SushipMentionsTable) do
		table.insert(nt,n)
		table.insert(nt,OPCODE_ISCODE)
		if i>1 then table.insert(nt,OPCODE_OR) end
	end
	-- 让对方玩家从上述列表中宣言1个卡名
	local code=Duel.AnnounceCard(1-tp,table.unpack(nt))
	-- 提示宣言的卡片卡名
	Duel.Hint(HINT_CARD,tp,code)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张与对方宣言卡名相同的卡
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,code):GetFirst()
	if tc then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	elseif c:IsRelateToEffect(e) then
		-- 不能加入的场合，这张卡回到持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 离场前置处理：获取并记录这张卡放置的指示物数量
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x66)
	e:GetLabelObject():SetLabel(ct)
end
-- ②效果的发动条件：这张卡被对方破坏的场合
function s.plpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
end
-- ②效果的效果处理：对方支付这张卡放置的指示物数量×500基本分
function s.plpop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()*500
	-- 对方基本分足够时，对方支付对应的基本分数值
	if val>0 and Duel.GetLP(1-tp)>=val then Duel.PayLPCost(1-tp,val) end
end
