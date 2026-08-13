--月華竜 ブラック・ローズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡特殊召唤成功时或者对方场上有5星以上的怪兽特殊召唤时发动。选择对方场上1只特殊召唤的怪兽回到持有者手卡。「月华龙 黑蔷薇」的效果1回合只能使用1次。
function c33698022.initial_effect(c)
	-- 为「月华龙 黑蔷薇」添加同调召唤手续：调整怪兽1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡特殊召唤成功时或者对方场上有5星以上的怪兽特殊召唤时发动。选择对方场上1只特殊召唤的怪兽回到持有者手卡。「月华龙 黑蔷薇」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33698022,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,33698022)
	e1:SetTarget(c33698022.thtg)
	e1:SetOperation(c33698022.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(33698022,1))
	e2:SetCode(EVENT_CUSTOM+33698022)
	c:RegisterEffect(e2)
	-- 或者对方场上有5星以上的怪兽特殊召唤时发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c33698022.evcon)
	e3:SetOperation(c33698022.evop)
	c:RegisterEffect(e3)
end
-- 过滤条件：这张卡为表侧表示，等级在5星以上，且控制者为指定玩家tp。
function c33698022.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsControler(tp)
end
-- 诱发条件：本次特殊召唤的怪兽中不包含「月华龙 黑蔷薇」自身，且对方（1-tp）场上有至少1只表侧表示5星以上的怪兽被特殊召唤。
function c33698022.evcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c33698022.cfilter,1,nil,1-tp)
end
-- 满足条件时，以「月华龙 黑蔷薇」自身为事件源，触发自定义事件EVENT_CUSTOM+33698022，用于让效果e2发动。
function c33698022.evop(e,tp,eg,ep,ev,re,r,rp)
	-- 以「月华龙 黑蔷薇」自身为对象，向系统触发自定义特殊召唤成功时点，从而联动诱发“对方场上有5星以上怪兽特殊召唤时”的效果。
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+33698022,re,r,rp,ep,ev)
end
-- 该卡的召唤方式为特殊召唤，并且能被送去手卡（没有“不能加入手卡”的限制）。
function c33698022.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 效果发动时的取对象处理：若在连锁中确认对象则检查其是否合法；若为发动时，则提示玩家选择对方场上1只特殊召唤怪兽，并将其登记为效果对象，同时设置本次操作的回手牌信息。
function c33698022.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c33698022.filter(chkc) end
	if chk==0 then return true end
	-- 向选择玩家显示提示文字“请选择要返回手牌的卡”，用于选择卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只满足条件（特殊召唤且能回手牌）的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c33698022.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统登记本次效果处理为“回到手牌”操作，对象为已选择的那只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时，取得效果对象卡，若该卡仍与本效果关联，则将其送回持有者手卡。
function c33698022.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回其持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
