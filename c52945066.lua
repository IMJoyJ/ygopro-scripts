--海晶乙女波動
-- 效果：
-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上有「海晶少女」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。自己场上有连接2以上的「海晶少女」怪兽存在的场合，再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
function c52945066.initial_effect(c)
	-- ①：自己场上有「海晶少女」连接怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。自己场上有连接2以上的「海晶少女」怪兽存在的场合，再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c52945066.con)
	e1:SetTarget(c52945066.target)
	e1:SetOperation(c52945066.activate)
	c:RegisterEffect(e1)
	-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52945066,0))  --"适用「海晶少女波动」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c52945066.handcon)
	c:RegisterEffect(e2)
end
-- 定义过滤器：判断卡片是否为表侧表示、属于「海晶少女」字段且为连接怪兽，用于检索自己场上是否存在符合条件的连接怪兽。
function c52945066.ccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 主要效果（①）的发动条件：自己场上存在至少1只表侧表示、属于「海晶少女」的连接怪兽时才能发动。
function c52945066.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以当前玩家视角看待的自己主要怪兽区是否存在至少1只满足ccfilter条件的卡（即表侧表示的「海晶少女」连接怪兽）。
	return Duel.IsExistingMatchingCard(c52945066.ccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 取对象处理：选择对方场上1只表侧表示且可被无效效果的怪兽作为效果对象，并为后续无效处理设定对象。
function c52945066.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若系统检查指定对象（chkc），则判断该对象是否位于对方怪兽区、由对方控制，并且是表侧表示且能被无效效果的怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 效果发动时（chk==0）检查是否存在至少1只合法目标：对方场上有表侧表示且可被无效效果的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给当前玩家弹出“请选择要无效的卡”的选择提示，供后续选择对象时显示说明。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方怪兽区选择1只表侧表示且可被无效效果的怪兽作为效果对象，并将该卡登记为当前连锁的处理对象。
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义追加判定过滤器：判断卡片是否为表侧表示、属于「海晶少女」且连接标记数量在2以上，用于是否追加“自己怪兽不受对方效果影响”的处理。
function c52945066.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(2)
end
-- 效果处理：将对象怪兽的效果无效化；若自己场上有连接2以上的「海晶少女」怪兽，则再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
function c52945066.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次效果选择的对象（对方场上被指定的表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的连锁无效化，并在该怪兽变里侧表示时重置此无效状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 获取自己场上全部表侧表示怪兽的集合，用于后续统一附加“不受对方效果影响”的状态。
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		-- 判断是否追加免疫效果：自己场上有连接2以上的「海晶少女」怪兽，且自己场上存在表侧表示怪兽时，满足追加条件。
		if Duel.IsExistingMatchingCard(c52945066.cfilter,tp,LOCATION_MZONE,0,1,nil) and g1:GetCount()>0 then
			-- 中断当前效果处理，使后续的免疫赋予处理与前段的无效处理视为不同时处理，以避免时点冲突。
			Duel.BreakEffect()
			local nc=g1:GetFirst()
			while nc do
				-- 再让自己场上的全部表侧表示怪兽直到回合结束时不受对方的效果影响。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetRange(LOCATION_MZONE)
				e3:SetCode(EFFECT_IMMUNE_EFFECT)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e3:SetValue(c52945066.efilter)
				e3:SetOwnerPlayer(tp)
				nc:RegisterEffect(e3)
				nc=g1:GetNext()
			end
		end
	end
end
-- 免疫过滤器：当效果来源的OwnerPlayer与当前处理效果的所有者不同（即对方的效果）时，该效果不对自己场上的怪兽生效。
function c52945066.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 定义手卡发动条件过滤器：判断卡片是否为表侧表示、属于「海晶少女」且连接标记数量在3以上，用于手卡发动的条件判定。
function c52945066.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 手卡发动条件：自己场上有连接3以上的「海晶少女」怪兽存在时，这张卡可以从手卡发动。
function c52945066.handcon(e)
	-- 检查以当前玩家视角看待的自己主要怪兽区是否存在至少1只满足hcfilter条件的卡（即表侧表示且连接标记3以上的「海晶少女」怪兽）。
	return Duel.IsExistingMatchingCard(c52945066.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
