--ヴェンデット・ナイトメア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从自己的手卡·场上把「复仇死者」怪兽任意数量解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升解放的怪兽数量的数值。
-- ②：自己的「复仇死者」仪式怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力上升1000。
function c33971095.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己的手卡·场上把「复仇死者」怪兽任意数量解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升解放的怪兽数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c33971095.lvtg)
	e2:SetOperation(c33971095.lvop)
	c:RegisterEffect(e2)
	-- ②：自己的「复仇死者」仪式怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,33971095)
	e3:SetCondition(c33971095.atkcon)
	e3:SetOperation(c33971095.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为「复仇死者」怪兽
function c33971095.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106)
end
-- 过滤函数，用于判断是否为满足条件的可选择对象
function c33971095.filter(c,tp)
	-- 判断是否为表侧表示的怪兽且等级大于等于1，并且玩家场上·手卡存在满足条件的可解放的「复仇死者」怪兽
	return c:IsFaceup() and c:IsLevelAbove(1) and Duel.CheckReleaseGroupEx(tp,c33971095.cfilter,1,REASON_COST,true,c,c)
end
-- 设置①效果的发动条件，检查是否有满足条件的怪兽可作为对象
function c33971095.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33971095.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c33971095.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的怪兽作为对象
	local tc=Duel.SelectTarget(tp,c33971095.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 选择1~99张满足条件的「复仇死者」怪兽进行解放
	local sg=Duel.SelectReleaseGroupEx(tp,c33971095.cfilter,1,99,REASON_COST,true,tc,tc)
	-- 将选择的怪兽进行解放
	Duel.Release(sg,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- ①效果的处理函数，将对象怪兽的等级提升
function c33971095.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的等级提升指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件函数，判断是否为「复仇死者」仪式怪兽攻击破坏对方怪兽
function c33971095.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	-- 判断攻击怪兽是否为当前战斗中的攻击怪兽
	return rc==Duel.GetAttacker() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsFaceup()
		and bit.band(rc:GetType(),0x81)==0x81 and rc:IsSetCard(0x106) and rc:IsControler(tp)
end
-- ②效果的处理函数，提升攻击怪兽的攻击力
function c33971095.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() then
		-- 提升攻击怪兽的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
