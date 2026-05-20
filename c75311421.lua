--ボティス
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己卡组上面把3张卡翻开。那之中有怪兽的场合，可以通过把那之内的1只除外来把那1只同名怪兽从卡组以及翻开的卡之中加入手卡。剩下的卡回到卡组。
-- ②：通常召唤的这张卡被送去墓地的回合的结束阶段才能发动。从自己卡组上面把3张卡翻开，用喜欢的顺序回到卡组上面。
function c75311421.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己卡组上面把3张卡翻开。那之中有怪兽的场合，可以通过把那之内的1只除外来把那1只同名怪兽从卡组以及翻开的卡之中加入手卡。剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c75311421.thtg)
	e1:SetOperation(c75311421.thop)
	c:RegisterEffect(e1)
	-- ②：通常召唤的这张卡被送去墓地的回合的结束阶段才能发动。（此部分为送去墓地时注册标记的处理）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c75311421.regcon)
	e2:SetOperation(c75311421.regop)
	c:RegisterEffect(e2)
	-- ②：通常召唤的这张卡被送去墓地的回合的结束阶段才能发动。从自己卡组上面把3张卡翻开，用喜欢的顺序回到卡组上面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c75311421.seqcon)
	e3:SetTarget(c75311421.seqtg)
	e3:SetOperation(c75311421.seqop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件与对象选择：检查自己卡组数量是否不小于3张，且自身是否能进行除外操作
function c75311421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己卡组数量是否至少有3张，且自己是否可以除外卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.IsPlayerCanRemove(tp) end
end
-- 过滤翻开的3张卡中可以除外的怪兽，且自己卡组中存在其同名卡
function c75311421.rmfilter(c,g)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and g:IsExists(c75311421.thfilter,1,c,c:GetCode())
end
-- 过滤卡组中与被除外卡同名且能加入手牌的卡
function c75311421.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果①的操作：翻开卡组上方3张卡，选择其中1只怪兽除外，并从卡组中将1只同名怪兽加入手牌，其余卡洗回卡组
function c75311421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己卡组的卡片数量不足3张则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 翻开（确认）自己卡组最上方的3张卡
	Duel.ConfirmDecktop(tp,3)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	-- 获取自己卡组的所有卡片
	local dg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local sg=g:Filter(c75311421.rmfilter,nil,dg)
	-- 若翻开的卡中有符合条件的怪兽，询问玩家是否发动除外并检索的效果
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(75311421,0)) then  --"是否除外并检索同名卡？"
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rc=sg:Select(tp,1,1,nil):GetFirst()
		-- 将选择的怪兽表侧表示除外
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=dg:FilterSelect(tp,c75311421.thfilter,1,1,rc,rc:GetCode())
		-- 将选择的同名怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
	-- 将自己卡组洗牌
	Duel.ShuffleDeck(tp)
end
-- 效果②的标记注册条件：这张卡是通常召唤且从怪兽区域送去墓地
function c75311421.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 效果②的标记注册操作：给自身注册一个持续到回合结束的Flag，用于记录被送去墓地
function c75311421.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(75311421,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：自身带有在回合结束前有效的Flag（即通常召唤的此卡在当前回合被送去墓地）
function c75311421.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(75311421)>0
end
-- 效果②的发动条件与对象选择：检查卡组数量是否大于2张
function c75311421.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方卡组数量是否大于2张（注：此处代码误将自己卡组写成了对方卡组）
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 效果②的操作：将自己卡组最上方的3张卡按喜欢的顺序放回卡组最上方
function c75311421.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己对自己的卡组最上方的3张卡进行排序
	Duel.SortDecktop(tp,tp,3)
end
