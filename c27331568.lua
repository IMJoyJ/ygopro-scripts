--荘厳なる機械天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放，以自己场上1只天使族·光属性怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力直到回合结束时上升解放的怪兽的等级×200。这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
function c27331568.initial_effect(c)
	-- ①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放，以自己场上1只天使族·光属性怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力直到回合结束时上升解放的怪兽的等级×200。这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27331568+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c27331568.cost)
	e1:SetTarget(c27331568.target)
	e1:SetOperation(c27331568.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡或场上的怪兽是否为「电子化天使」仪式怪兽且等级大于等于1，并且自己场上是否存在满足条件的天使族·光属性怪兽作为对象
function c27331568.cfilter(c,tp)
	return c:IsSetCard(0x2093) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(1)
		-- 检查自己场上是否存在满足条件的天使族·光属性怪兽作为对象
		and Duel.IsExistingTarget(c27331568.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示的天使族·光属性怪兽
function c27331568.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 检查玩家是否能解放满足条件的「电子化天使」仪式怪兽，并选择一张进行解放
function c27331568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能解放满足条件的「电子化天使」仪式怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c27331568.cfilter,1,REASON_COST,true,nil,tp) end
	-- 选择一张满足条件的「电子化天使」仪式怪兽进行解放
	local g=Duel.SelectReleaseGroupEx(tp,c27331568.cfilter,1,1,REASON_COST,true,nil,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选择的怪兽从游戏中解放
	Duel.Release(g,REASON_COST)
end
-- 选择自己场上的一只天使族·光属性怪兽作为效果对象
function c27331568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27331568.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只满足条件的天使族·光属性怪兽作为对象
	Duel.SelectTarget(tp,c27331568.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将作为对象的怪兽的攻击力和守备力提升解放怪兽等级×200
function c27331568.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local c=e:GetHandler()
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽的攻击力直到回合结束时上升解放的怪兽的等级×200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 这个回合，作为对象的怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(c27331568.distg)
		e3:SetLabel(tc:GetFieldID())
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		-- 将效果注册到场上
		Duel.RegisterEffect(e4,tp)
	end
end
-- 用于判断是否为从额外卡组特殊召唤并参与战斗的对方怪兽，若是则使其效果无效
function c27331568.distg(e,c)
	if c:GetFlagEffect(27331568)>0 then return true end
	if c:IsSummonLocation(LOCATION_EXTRA) and c:GetBattleTarget()~=nil and c:GetBattleTarget():GetFieldID()==e:GetLabel() then
		c:RegisterFlagEffect(27331568,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		-- 手动刷新场上受影响的卡的无效状态
		Duel.AdjustInstantly(e:GetHandler())
		return true
	end
	return false
end
