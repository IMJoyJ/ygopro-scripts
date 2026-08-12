--メガリス・フール
-- 效果：
-- 「巨石遗物」卡降临
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡仪式召唤的场合，以自己墓地1只仪式怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。那之后，作为对象的怪兽加入手卡。
-- ②：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡·卡组把1只「巨石遗物」仪式怪兽仪式召唤。
function c78990927.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合，以自己墓地1只仪式怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。那之后，作为对象的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78990927,0))  --"改变等级"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,78990927)
	e1:SetCondition(c78990927.thcon)
	e1:SetTarget(c78990927.thtg)
	e1:SetOperation(c78990927.thop)
	c:RegisterEffect(e1)
	-- 注册一个仪式召唤效果，允许从手卡或卡组仪式召唤「巨石遗物」仪式怪兽，并解放手卡或场上的怪兽作为祭品
	local e2=aux.AddRitualProcGreater2(c,c78990927.filter,LOCATION_HAND+LOCATION_DECK,nil,nil,true)
	e2:SetDescription(aux.Stringid(78990927,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,78990928)
	e2:SetCondition(c78990927.rscon)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己墓地中等级与自身当前等级不同、且可以加入手牌的仪式怪兽
function c78990927.thfilter(c,lv)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsLevel(lv) and c:IsAbleToHand()
end
-- 条件函数：这张卡仪式召唤成功的场合
function c78990927.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 目标过滤与合法性检测：检查自身等级并确认墓地中是否存在可作为对象的仪式怪兽
function c78990927.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78990927.thfilter(chkc,lv) end
	if chk==0 then return c:IsLevelAbove(1) and c:IsRelateToEffect(e)
		-- 检查自己墓地中是否存在至少1只符合条件的仪式怪兽
		and Duel.IsExistingTarget(c78990927.thfilter,tp,LOCATION_GRAVE,0,1,nil,lv) end
	-- 在界面上提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中1只符合条件的仪式怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78990927.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,lv)
	-- 设置效果处理信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的操作函数：改变自身等级，那之后将对象怪兽加入手牌
function c78990927.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 这张卡的等级变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 中断效果处理，使前后的等级变化和加入手牌不视为同时进行
		Duel.BreakEffect()
		-- 将作为对象的怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数：筛选「巨石遗物」字段的卡片
function c78990927.filter(c,e,tp,chk)
	return c:IsSetCard(0x138)
end
-- 条件函数：自己或对方的主要阶段
function c78990927.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前游戏阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
