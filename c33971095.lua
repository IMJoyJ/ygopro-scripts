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
-- 过滤函数：判定一张卡是否为怪兽且属于「复仇死者」系列，用于筛选可解放的怪兽。
function c33971095.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106)
end
-- 对象筛选函数：检查候选对象是否为表侧表示且等级≥1，并确认自己场上·手卡存在至少1只可解放的「复仇死者」怪兽（不能选对象本身）。
function c33971095.filter(c,tp)
	-- （接上行）确认候选对象为表侧表示、等级≥1，且自己场上·手卡存在可解放的「复仇死者」怪兽。
	return c:IsFaceup() and c:IsLevelAbove(1) and Duel.CheckReleaseGroupEx(tp,c33971095.cfilter,1,REASON_COST,true,c,c)
end
-- ①效果的发动目标处理：若连锁中指定对象，则验证该对象是否合法；若为发动合法性检查，则确认已满足cost条件且场上存在合法对象。
function c33971095.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33971095.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 发动条件判定：确认自己场上存在至少1只满足条件的表侧表示怪兽可以作为对象。
		and Duel.IsExistingTarget(c33971095.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1张满足条件的表侧表示怪兽作为效果对象（取对象）。
	local tc=Duel.SelectTarget(tp,c33971095.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 从自己手卡·场上选择任意数量（1~99张）的「复仇死者」怪兽作为解放代价，且不能选择对象怪兽自身。
	local sg=Duel.SelectReleaseGroupEx(tp,c33971095.cfilter,1,99,REASON_COST,true,tc,tc)
	-- 将选择的「复仇死者」怪兽解放，作为发动①效果的代价。
	Duel.Release(sg,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- ①效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则赋予其等级上升效果。
function c33971095.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象怪兽。
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
-- ②效果的触发条件判断：自己的「复仇死者」仪式怪兽与对方怪兽战斗并战斗破坏对方怪兽。
function c33971095.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	-- 判定进行攻击并战斗破坏对方怪兽的就是攻击怪兽本身，且该怪兽进行过与对方怪兽的战斗并处于表侧表示。
	return rc==Duel.GetAttacker() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsFaceup()
		and bit.band(rc:GetType(),0x81)==0x81 and rc:IsSetCard(0x106) and rc:IsControler(tp)
end
-- ②效果处理：对符合条件的那只自己怪兽发动攻击力上升效果。
function c33971095.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得进行攻击并战斗破坏对方怪兽的攻击怪兽。
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
