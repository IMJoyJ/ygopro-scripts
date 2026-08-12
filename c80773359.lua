--A BF－神立のオニマル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「强袭黑羽-神立之鬼丸刀鸟」的③的效果在决斗中只能使用1次。
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡不会被效果破坏。
-- ③：以自己墓地1只「黑羽」怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
-- ④：只用同调怪兽为素材作同调召唤的这张卡攻击的场合，伤害步骤内这张卡的攻击力上升3000。
function c80773359.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。 / ④：只用同调怪兽为素材作同调召唤的这张卡攻击的场合，伤害步骤内这张卡的攻击力上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c80773359.tncon)
	e1:SetOperation(c80773359.tnop)
	c:RegisterEffect(e1)
	-- 「黑羽」怪兽为素材作同调召唤 / 只用同调怪兽为素材作同调召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c80773359.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：以自己墓地1只「黑羽」怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80773359,0))  --"等级变化"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,80773359+EFFECT_COUNT_CODE_DUEL)
	e4:SetTarget(c80773359.lvtg)
	e4:SetOperation(c80773359.lvop)
	c:RegisterEffect(e4)
end
c80773359.treat_itself_tuner=true
-- 检查同调素材，若包含「黑羽」怪兽则flag标记第1位，若全为同调怪兽则flag标记第2位，并将flag值存入e1
function c80773359.valcheck(e,c)
	local flag=0
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		flag=flag|1
	end
	if g:GetCount()>0 and not g:IsExists(c80773359.mfilter,1,nil) then
		flag=flag|2
	end
	e:GetLabelObject():SetLabel(flag)
end
-- 过滤非同调怪兽的卡
function c80773359.mfilter(c)
	return not c:IsType(TYPE_SYNCHRO)
end
-- 判定这张卡是否同调召唤成功，且同调素材满足特定条件
function c80773359.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()>0
end
-- 根据同调素材的检查结果，赋予这张卡当作调整使用的效果，和/或攻击时攻击力上升3000的效果
function c80773359.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()&1==1 then
		-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if e:GetLabel()&2==2 then
		-- ④：只用同调怪兽为素材作同调召唤的这张卡攻击的场合，伤害步骤内这张卡的攻击力上升3000。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetCondition(c80773359.atkcon)
		e2:SetValue(3000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(80773359,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(80773359,1))  --"只用同调怪兽为素材作同调召唤"
	end
end
-- 判定是否在伤害步骤（或伤害计算时）且自身是攻击怪兽
function c80773359.atkcon(e)
	local c=e:GetHandler()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为伤害步骤或伤害计算时，且自身为攻击怪兽
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttacker()==c
end
-- 过滤自己墓地中等级与自身不同且大于等于1级的「黑羽」怪兽
function c80773359.lvfilter(c,lv)
	return c:IsSetCard(0x33) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果3的发动准备：选择自己墓地1只符合条件的「黑羽」怪兽作为对象
function c80773359.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c80773359.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 判定自己墓地是否存在等级与自身不同且大于等于1级的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c80773359.lvfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 给玩家发送选择卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择墓地1只符合条件的「黑羽」怪兽作为效果对象
	Duel.SelectTarget(tp,c80773359.lvfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 效果3的处理：使这张卡的等级变成与作为对象的墓地怪兽相同
function c80773359.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这张卡的等级变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
