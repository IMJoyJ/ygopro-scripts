--巳剣之磐境
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。
local s,id,o=GetID()
-- 初始化卡片效果：注册自由时点可发动的空效果（永续魔陷卡发动必需）、赋予「巳剑」仪式怪兽效果对象抗性的永续效果（对应①效果）、以及以墓地4张「巳剑」卡为对象的起动回卡组效果（对应②效果）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tfilter)
	e2:SetValue(s.evalue)
	c:RegisterEffect(e2)
	-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。（这个卡名的②的效果1回合只能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- ①效果的保护对象过滤函数：选择自己场上仪式召唤的「巳剑」仪式怪兽
function s.tfilter(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x1c3)
end
-- ①效果的抗性判定函数：仅当效果发动者为对方、且处理该效果的怪兽卡是从额外卡组特殊召唤的怪兽时适用（使保护仅对额外特召怪兽的效果对象生效）
function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and rp==1-e:GetHandlerPlayer()
end
-- ②效果的取对象过滤函数：「巳剑之磐境」以外的「巳剑」卡且能够回到卡组
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToDeck()
end
-- ②效果的目标阶段：取对象合法性检查，以及发动条件确认——自己墓地存在4张可作为对象的「巳剑」卡，且对方场上没有怪兽或对方玩家能够解放怪兽
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 发动条件之一：检查自己墓地是否存在4张满足条件且能成为效果对象的「巳剑」卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,4,nil)
		-- 发动条件之二：检查对方场上没有怪兽，或对方玩家能够进行解放（否则无法要求对方解放怪兽）
		and (Duel.GetFieldGroup(tp,0,LOCATION_MZONE)==0 or Duel.IsPlayerCanRelease(1-tp)) end
	-- 向玩家显示选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择4张满足条件的「巳剑」卡并设为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	-- 设置操作信息：本连锁确定将这4张对象卡回到卡组（CATEGORY_TODECK）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果的处理：将作为对象的「巳剑」卡（排除受王家长眠之谷影响的）回到卡组并洗牌；回卡组成功且对方场上有可解放的怪兽时，再让对方选择自身场上1只怪兽并以规则原因解放
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本次连锁关联的对象卡，并过滤掉受王家长眠之谷影响而不能操作的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 若对象卡存在，则把它们以效果原因送回卡组最顶端并洗卡组；实际送回数量需大于0才继续后续处理
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 取得上一次回卡组操作实际被操作的卡组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 检查对方玩家场上是否存在至少1张可解放的卡（作为要求对方解放的前提）
			and Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) then
			-- 让对方玩家从自身场上选择1张可解放的卡
			local sg=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
			if sg:GetCount()>0 then
				-- 中断当前效果处理，使解放动作与回卡组动作视为不同时处理（避免错时点问题）
				Duel.BreakEffect()
				-- 显示对方选中的要解放的卡被选中的动画效果
				Duel.HintSelection(sg)
				-- 以规则原因解放对方选择的1只怪兽（让对方必须把自身场上1只怪兽解放）
				Duel.Release(sg,REASON_RULE,1-tp)
			end
		end
	end
end
