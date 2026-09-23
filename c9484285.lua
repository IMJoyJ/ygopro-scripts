--レイズ・ムーンの望 スクイーズ－ジャックポット
local s,id,o=GetID()
-- 初始化卡片效果：注册超量召唤手续、攻击诱导永续效果、弹回卡组底以及吸取对方卡组顶作为超量素材的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：7星怪兽×2只以上
	aux.AddXyzProcedure(c,nil,7,2,nil,nil,99)
	-- ①：只要这张卡在怪兽区域存在，对方怪兽不能选择这张卡以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡超量召唤的场合，或者对方把怪兽从手卡特殊召唤的场合，把这张卡的任意数量的超量素材取除才能发动。选最多有取除数量的对方场上的卡回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tdcon)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tdcon2)
	c:RegisterEffect(e3)
	-- ③：卡从对方卡组离开的场合才能发动。从对方卡组最上面把1张卡在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_MOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.ldcon1)
	e4:SetOperation(s.ldop1)
	c:RegisterEffect(e4)
	-- ③：卡从对方卡组离开的场合才能发动。从对方卡组最上面把1张卡在这张卡下面重叠作为超量素材。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_MOVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.ldcon2)
	e5:SetOperation(s.ldop2)
	c:RegisterEffect(e5)
	local e5l=e5:Clone()
	e5l:SetCode(EVENT_LEAVE_DECK)
	c:RegisterEffect(e5l)
	-- ③：卡从对方卡组离开的场合才能发动。从对方卡组最上面把1张卡在这张卡下面重叠作为超量素材。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.rcon)
	e6:SetOperation(s.rop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_BREAK_EFFECT)
	c:RegisterEffect(e7)
	-- 从对方卡组最上面把1张卡在这张卡下面重叠作为超量素材。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_CUSTOM+id)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.mtcon)
	e8:SetTarget(s.mttg)
	e8:SetOperation(s.mtop)
	c:RegisterEffect(e8)
end
-- 攻击对象限制：不能选择自身以外的怪兽
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果②的发动条件判定：自身超量召唤成功
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动代价：取除自身任意数量的超量素材并记录取除数量
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取对方场上可返回卡组的卡片数量
	local rt=Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 弹回卡组效果的目标判定及操作信息设置
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可返回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将对方场上的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,e:GetLabel(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：选最多有取除数量的对方场上的卡回到持有者卡组最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取对方场上可返回卡组的卡
	local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if tg:GetCount()<ct then return end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=tg:Select(tp,ct,ct,nil)
	if g:GetCount()>0 then
		-- 高亮显示所选卡片
		Duel.HintSelection(g)
		-- 将所选卡片按自选顺序放置在卡组底端
		aux.PlaceCardsOnDeckBottom(tp,g)
	end
end
-- 效果②的发动条件判定：对方从手牌特殊召唤怪兽
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end
-- 过滤对方从卡组以非抽卡方式离开的卡片
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and not c:IsLocation(LOCATION_DECK)
		and c:IsPreviousControler(1-tp) and not c:IsReason(REASON_DRAW)
end
-- 判定是否非连锁处理中发生对方卡片离开卡组
function s.ldcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方卡片离开卡组且非连锁处理中
	return eg:IsExists(s.cfilter,1,nil,tp) and rp==1-tp and not Duel.IsChainSolving()
end
-- 直接触发自定义事件以发动素材吸收效果
function s.ldop1(e,tp,eg,ep,ev,re,r,rp)
	-- 为自身触发自定义时点
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,0,0)
end
-- 判定是否在连锁处理中发生对方卡片离开卡组
function s.ldcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方卡片离开卡组且当前正在连锁处理中
	return eg:IsExists(s.cfilter,1,nil,tp) and rp==1-tp and Duel.IsChainSolving()
end
-- 在自身注册标记以延迟到连锁处理完毕触发
function s.ldop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 连锁处理完毕检查自身是否存在延迟触发标记
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 重置延迟标记并触发自定义事件
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	-- 为自身触发自定义时点
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,0,0)
end
-- 素材吸收效果的发动条件判定：非伤害步骤
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
end
-- 素材吸收效果的目标判定及提示
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否为超量怪兽且对方卡组存在卡片
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：将对方卡组顶端的1张卡作为自身的超量素材叠放
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if c:IsRelateToChain() and g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 禁用洗牌检查
		Duel.DisableShuffleCheck()
		if tc:IsCanOverlay() then
			-- 将卡片作为自身的超量素材叠放
			Duel.Overlay(c,g)
		else
			-- 若不能作为超量素材，依据规则送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
