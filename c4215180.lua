--ロリポー☆ヤミー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以对方墓地1张卡为对象才能发动。那张卡回到卡组。同调怪兽的效果特殊召唤的场合，也能作为代替把作为对象的卡除外。
local s,id,o=GetID()
-- 创建并注册四个效果：e1为①的规则特殊召唤效果（手牌、场上存在连接1或2星同调怪兽时可从手卡特殊召唤，且该特殊召唤一回合只能有1次）；e2为②的通常召唤成功时诱发效果；e3为e2的克隆，对应特殊召唤成功时诱发；e4为不入连锁的辅助效果，用于标记此卡是否因同调怪兽效果特殊召唤，以决定②中能否选择除外代替。
function s.initial_effect(c)
	-- 对应①及效果原文：‘这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 对应②的效果原文：‘②：这张卡召唤·特殊召唤的场合，以对方墓地1张卡为对象才能发动。那张卡回到卡组。同调怪兽的效果特殊召唤的场合，也能作为代替把作为对象的卡除外。’（本效果为通常召唤成功时的诱发效果；特殊召唤成功时由e3复制实现）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 对应②中的‘同调怪兽的效果特殊召唤的场合，也能作为代替把作为对象的卡除外’的辅助检测效果（不入连锁）。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 定义过滤函数：筛选出我方场上表侧表示的等级2同调怪兽或连接1连接怪兽，用于①的召唤条件判定。
function s.filter(c)
	return (c:IsLevel(2) and c:IsType(TYPE_SYNCHRO) or c:IsLink(1) and c:IsType(TYPE_LINK)) and c:IsFaceup()
end
-- 规则特殊召唤的条件函数：若c为nil则返回true表示可查询；否则需满足主要怪兽区有空位，且我方场上存在符合s.filter的表侧表示怪兽，才能从手卡特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者主要怪兽区域是否有空位，保证能够特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查我方场上是否存在至少1张满足s.filter的表侧表示怪兽，即连接1怪兽或2星同调怪兽。
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标选择与合法性检查：先校验对象必须是对方墓地卡；再确认存在可回卡组的对象；若本卡带‘同调效果特招’标记则设置e标签为1，允许处理阶段选择除外代替；随后提示玩家从对方墓地选择1张卡，并设置回卡组操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) end
	-- 发动合法性判定：对方墓地是否存在至少1张能够加入持有者卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 向玩家发出选择目标的提示消息，提示文字为‘请选择效果的对象’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方墓地选择1张能够回卡组的卡作为效果对象，并登记为当前连锁的取对象卡。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本次效果将以效果原因把已选择的1张卡返回卡组（CATEGORY_TODECK），供后续卡片效果进行时点响应判断。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取得对象卡；若对象仍与效果关联且不受王家长眠之谷影响，则根据对象能否回卡组、能否除外以及玩家的选择决定：默认回卡组并洗牌，若因同调怪兽效果特招且玩家选择是则改为除外。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的当前对象卡，即发动②时选择的那张对方墓地卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查该对象卡是否仍与本次效果e保持关联（未离场或对象关系未失效），并且不受王家长眠之谷影响；若条件不满足则直接终止处理。
	if not (tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)) then return end
	local b1=tc:IsAbleToDeck()
	local b2=e:GetLabel()==1 and tc:IsAbleToRemove()
	-- 判断分支条件：若对象能回卡组，且（不能除外或玩家不选择代替除外），则执行回卡组；否则若对象能除外，则执行除外。
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否作为代替除外？"
		-- 将对象卡以效果原因送回其持有者卡组，并置于洗牌位置，最终洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif b2 then
		-- 将对象卡以表侧表示除外，实现‘作为代替把作为对象的卡除外’。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 不入连锁的辅助效果：当这张卡特殊召唤成功时，检查引发此次特殊召唤的效果是否为同调怪兽的效果；若是则给这张卡登记id标记，供②效果在决定能否选择代替除外时使用。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
