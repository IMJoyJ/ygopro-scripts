--月華竜 ブラック・ローズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡特殊召唤成功时或者对方场上有5星以上的怪兽特殊召唤时发动。选择对方场上1只特殊召唤的怪兽回到持有者手卡。「月华龙 黑蔷薇」的效果1回合只能使用1次。
function c33698022.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡特殊召唤成功时发动
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
	-- 对方场上有5星以上的怪兽特殊召唤时发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c33698022.evcon)
	e3:SetOperation(c33698022.evop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的怪兽：表侧表示、等级5以上、为指定玩家控制
function c33698022.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsControler(tp)
end
-- 判断是否满足触发条件：对方场上有5星以上的怪兽特殊召唤且不包含自身
function c33698022.evcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c33698022.cfilter,1,nil,1-tp)
end
-- 触发自定义事件EVENT_CUSTOM+33698022，用于发动效果
function c33698022.evop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发一个自定义事件，使效果可以被正常处理
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+33698022,re,r,rp,ep,ev)
end
-- 过滤满足条件的怪兽：特殊召唤、可以送入手牌
function c33698022.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 设置效果目标：选择对方场上1只特殊召唤的怪兽作为目标
function c33698022.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c33698022.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的目标怪兽
	local g=Duel.SelectTarget(tp,c33698022.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理效果：将目标怪兽送入持有者手牌
function c33698022.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理目标
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
