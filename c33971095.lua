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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的「复仇死者」仪式怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力上升1000。
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
-- 过滤条件函数：筛选「复仇死者」怪兽卡
function c33971095.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106)
end
-- 过滤条件函数：筛选自己场上等级1以上的表侧表示怪兽，且排除它自己后手卡·场上仍存在可解放的「复仇死者」怪兽
function c33971095.filter(c,tp)
	-- 检查该怪兽是否为表侧表示且拥有1星以上等级，并确认排除自身外手卡·场上至少有1只可作为代价解放的「复仇死者」怪兽
	return c:IsFaceup() and c:IsLevelAbove(1) and Duel.CheckReleaseGroupEx(tp,c33971095.cfilter,1,REASON_COST,true,c,c)
end
-- ①效果的目标选择与代价检查函数：确认能支付解放代价且存在可成为对象的自己场上表侧表示怪兽
function c33971095.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33971095.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的表侧表示怪兽作为效果对象
		and Duel.IsExistingTarget(c33971095.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧表示怪兽作为对象并获取该卡
	local tc=Duel.SelectTarget(tp,c33971095.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 让玩家从手卡·场上（排除对象怪兽自身）选择1至99只「复仇死者」怪兽用于作为代价解放
	local sg=Duel.SelectReleaseGroupEx(tp,c33971095.cfilter,1,99,REASON_COST,true,tc,tc)
	-- 将选择的「复仇死者」怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- ①效果的处理函数：若对象怪兽仍表侧表示且与效果关联，则使其等级直到回合结束时上升等于解放数量的数值
function c33971095.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象选择的自己场上怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级直到回合结束时上升解放的怪兽数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件函数：判断战斗破坏对方怪兽并送去墓地的是否为自己场上表侧表示且正在攻击的「复仇死者」仪式怪兽
function c33971095.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	-- 检查触发事件的怪兽是否为本次攻击怪兽、与对方怪兽进行了战斗且在场上表侧表示
	return rc==Duel.GetAttacker() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsFaceup()
		and bit.band(rc:GetType(),0x81)==0x81 and rc:IsSetCard(0x106) and rc:IsControler(tp)
end
-- ②效果的处理函数：若攻击的自己怪兽仍表侧表示存在，则使其攻击力永久上升1000
function c33971095.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗发起攻击的自己怪兽
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() then
		-- 那只自己怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
