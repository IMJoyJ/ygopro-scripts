--ラス・オブ・ネオス
-- 效果：
-- ①：以自己的怪兽区域1只「元素英雄 新宇侠」为对象才能发动。那只「元素英雄 新宇侠」回到持有者卡组，场上的卡全部破坏。
function c52098461.initial_effect(c)
	-- 记录这张卡的效果文本中提到了卡号89943723（元素英雄 新宇侠），用于支持涉及“卡名记述”的检索与判定（如手牌交换、卡名参照等）。
	aux.AddCodeList(c,89943723)
	-- 向这张卡注册系列字段0x3008，使其能正确匹配和判定「元素英雄 新宇侠」等属于该字段的怪兽，以支持效果文本中的相关条件。
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：以自己的怪兽区域1只「元素英雄 新宇侠」为对象才能发动。那只「元素英雄 新宇侠」回到持有者卡组，场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52098461.target)
	e1:SetOperation(c52098461.activate)
	c:RegisterEffect(e1)
end
-- 定义对象选择过滤函数：候选卡必须为表侧表示、卡号是89943723（元素英雄 新宇侠），并且能被返回卡组。
function c52098461.filter(c)
	return c:IsFaceup() and c:IsCode(89943723) and c:IsAbleToDeck()
end
-- 发动效果的目标处理函数：连锁选择时确认对象是自己场上符合条件的“元素英雄 新宇侠”；发动合法性检查确认存在可选对象，且场上除本卡外至少存在2张卡，保证后续“返回卡组并破坏全军”的处理可以执行。
function c52098461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c52098461.filter(chkc) end
	-- 合法发动检查：确认自己怪兽区域存在至少1只符合条件（表侧·元素英雄 新宇侠·可回卡组）的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c52098461.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 合法发动检查：场上除这张新宇之怒以外还存在至少2张卡，以确保新宇侠返回卡组后，“场上的卡全部破坏”的效果有足够的对象处理。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 给玩家显示“请选择要返回卡组的卡”的选择提示，并准备从自己场上选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己怪兽区域选择1只符合条件的新宇侠作为对象，并将其记录为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c52098461.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取场上除这张新宇之怒以外的全部卡（包括自己场上与对方场上的卡），作为“全部破坏”的候选集合。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	dg:RemoveCard(g:GetFirst())
	-- 设置操作信息：本次连锁包含把对象新宇侠返回卡组（CATEGORY_TODECK）的处理，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：本次连锁包含破坏场上除本卡以外全部卡（CATEGORY_DESTROY）的处理，数量为dg中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理函数：先取回连锁对象新宇侠，若其仍与该效果关联且仍然满足条件，则将其送回持有者卡组并洗牌；在成功送回且该卡位于卡组时，继续把场上除本卡以外的所有卡破坏。
function c52098461.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第1个对象卡，即被选择的那只「元素英雄 新宇侠」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c52098461.filter(tc)
		-- 将对象新宇侠以效果原因送回持有者卡组（洗牌），并确认实际送回成功且该卡确实处于卡组中，才继续执行破坏处理。
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 获取场上除发动效果的这张卡以外的全部卡（包含双方怪兽区和魔法陷阱区的卡），作为“场上的卡全部破坏”的破坏对象集合。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 以效果原因将集合g中的卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
