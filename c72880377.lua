--ブラック・ホール・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，场上的怪兽被不以自身为对象的卡的效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从卡组把1张「黑洞」加入手卡。
-- ③：场上的这张卡不会被效果破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果（①效果：手卡/墓地特召；②效果：特召成功时注册回合结束检索；③效果：场上抗性；以及全局破坏检测）
function s.initial_effect(c)
	-- ③：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡·墓地存在，场上的怪兽被不以自身为对象的卡的效果破坏的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从卡组把1张「黑洞」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- ①：这张卡在手卡·墓地存在，场上的怪兽被不以自身为对象的卡的效果破坏的场合才能发动。这张卡特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.descheck)
		-- 注册全局环境效果，用于持续监测场上怪兽被破坏的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局破坏检测函数，用于判断是否有怪兽被不取对象的效果破坏，并触发自定义事件
function s.descheck(e,tp,eg,ep,ev,re,r,rp)
	local res=false
	-- 遍历所有被破坏的卡片
	for tc in aux.Next(eg) do
		if tc:IsLocation(LOCATION_MZONE) and r&REASON_EFFECT>0 then
			if re==nil or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
				res=true
				break
			end
			-- 获取当前连锁的对象卡片组
			local tg=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TARGET_CARDS)
			if tg==nil or not tg:IsContains(tc) then
				res=true
				break
			end
		end
	end
	-- 若存在满足条件的破坏，则触发自定义事件，以满足手卡·墓地特召效果的发动时点
	if res then Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,tp,0) end
end
-- 特殊召唤效果的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动准备阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息，用于连锁处理的预告
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡在效果处理时仍存在于原本位置，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 注册一个在回合结束阶段触发的延迟效果，用于检索「黑洞」
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从卡组把1张「黑洞」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将回合结束阶段检索「黑洞」的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤卡组中名为「黑洞」且能加入手牌的卡
function s.filter(c)
	return c:IsCode(53129443) and c:IsAbleToHand()
end
-- 回合结束阶段检索「黑洞」的具体效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在屏幕上显示该卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的「黑洞」
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
