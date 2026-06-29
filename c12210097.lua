--巳剣之磐境
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把自己场上的「巳剑」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
-- ②：以「巳剑之磐境」以外的自己墓地4张「巳剑」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自身场上1只怪兽解放。
local s,id,o=GetID()
-- 注册激活卡片、对象抗性以及墓地卡片回收并迫使对方解放怪兽的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己场上的「巨石遗物」仪式怪兽作为从额外卡组特殊召唤的怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tfilter)
	e2:SetValue(s.evalue)
	c:RegisterEffect(e2)
	-- ②：以「巨石遗物之门户」以外的自己墓地4张「巨石遗物」卡为对象才能发动。那些卡回到卡组。对方场上有怪兽存在的场合，再让对方必须把自己场上1只怪兽解放。
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
-- 仪式怪兽与「巨石遗物」怪兽的过滤条件
function s.tfilter(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x1c3)
end
-- 判断该效果是否来自对方从额外卡组特殊召唤的怪兽
function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and rp==1-e:GetHandlerPlayer()
end
-- 墓地「巨石遗物」回收卡片的过滤条件
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToDeck()
end
-- 墓地回收与解放效果的发动准备及对象选择
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少4张满足条件的「巨石遗物」卡片
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,4,nil)
		-- 检查对方场上没有怪兽，或者对方玩家是否能执行解放操作
		and (Duel.GetFieldGroup(tp,0,LOCATION_MZONE)==0 or Duel.IsPlayerCanRelease(1-tp)) end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地中4张满足条件的「巨石遗物」卡片作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	-- 设置操作信息为将选中的4张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 墓地回收与解放效果的执行
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取相关卡片中未受墓地无效效果影响的有效回收目标
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 若卡片成功送回卡组并洗牌
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 获取实际上送回卡组或额外卡组的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			-- 若选中的卡片有一部分已成功返回卡组，且对方场上存在怪兽并能够执行解放
			and Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) then
			-- 由对方玩家选择其场上准备解放的1只怪兽
			local sg=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
			if sg:GetCount()>0 then
				-- 切断效果处理的连锁时点
				Duel.BreakEffect()
				-- 确认并点亮对方选择解放的怪兽
				Duel.HintSelection(sg)
				-- 将对方选中的那只怪兽解放
				Duel.Release(sg,REASON_RULE,1-tp)
			end
		end
	end
end
