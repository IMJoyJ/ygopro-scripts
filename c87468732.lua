--変導機咎 クロックアーク
-- 效果：
-- ←4 【灵摆】 4→
-- ①：自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合，这张卡的灵摆区域位置的以下效果适用。
-- ●左侧：这张卡的灵摆刻度下降3。
-- ●右侧：这张卡的灵摆刻度上升4。
-- ②：对方准备阶段才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：这张卡往中央以外的主要怪兽区域特殊召唤的场合破坏。
-- ②：这张卡不会被战斗破坏。
-- ③：对方结束阶段，以自己的灵摆区域1张卡为对象才能发动。那张卡破坏，这张卡在自己的灵摆区域放置。
function c87468732.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合，这张卡的灵摆区域位置的以下效果适用。●左侧：这张卡的灵摆刻度下降3。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c87468732.sccon1)
	e1:SetValue(-3)
	c:RegisterEffect(e1)
	local e8=e1:Clone()
	e8:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e8)
	-- ①：自己场上的怪兽不存在的场合或者只有灵摆怪兽的场合，这张卡的灵摆区域位置的以下效果适用。●右侧：这张卡的灵摆刻度上升4。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c87468732.sccon2)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	local e9=e2:Clone()
	e9:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e9)
	-- ②：对方准备阶段才能发动。灵摆区域的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87468732,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c87468732.spcon)
	e3:SetTarget(c87468732.sptg)
	e3:SetOperation(c87468732.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡往中央以外的主要怪兽区域特殊召唤的场合破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c87468732.descon)
	e4:SetOperation(c87468732.desop)
	c:RegisterEffect(e4)
	-- ②：这张卡不会被战斗破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	-- ③：对方结束阶段，以自己的灵摆区域1张卡为对象才能发动。那张卡破坏，这张卡在自己的灵摆区域放置。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(87468732,1))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(c87468732.tpcon)
	e7:SetTarget(c87468732.tptg)
	e7:SetOperation(c87468732.tpop)
	c:RegisterEffect(e7)
end
-- 过滤函数：过滤出里侧表示的卡片或者非灵摆怪兽
function c87468732.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_PENDULUM)
end
-- 灵摆刻度下降效果的适用条件：这张卡在左侧灵摆区域，且自己场上没有怪兽或只有灵摆怪兽
function c87468732.sccon1(e)
	-- 检查这张卡是否在左侧灵摆区域，且自己场上不存在非灵摆怪兽（即没有怪兽或只有灵摆怪兽）
	return e:GetHandler()==Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,0) and not Duel.IsExistingMatchingCard(c87468732.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 灵摆刻度上升效果的适用条件：这张卡在右侧灵摆区域，且自己场上没有怪兽或只有灵摆怪兽
function c87468732.sccon2(e)
	-- 检查这张卡是否在右侧灵摆区域，且自己场上不存在非灵摆怪兽（即没有怪兽或只有灵摆怪兽）
	return e:GetHandler()==Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1) and not Duel.IsExistingMatchingCard(c87468732.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的条件函数：当前回合玩家是对方
function c87468732.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的靶向与可行性检查函数
function c87468732.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c87468732.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 破坏效果的条件函数：检查特殊召唤的怪兽区域序号是否不等于2（中央位置）且小于5（主要怪兽区域）
function c87468732.descon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	return seq<5 and seq~=2
end
-- 破坏效果的执行函数
function c87468732.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 放置到灵摆区域效果的条件函数：当前回合玩家是对方
function c87468732.tpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：过滤出表侧表示的灵摆怪兽
function c87468732.tpfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 放置到灵摆区域效果的靶向与可行性检查函数
function c87468732.tptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and c87468732.tpfilter(chkc) end
	-- 检查自己的灵摆区域是否存在可以作为对象的表侧表示灵摆卡
	if chk==0 then return Duel.IsExistingTarget(c87468732.tpfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 并且检查自己的灵摆区域是否至少有一个空格可用
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己灵摆区域的1张表侧表示灵摆卡作为效果对象
	local g=Duel.SelectTarget(tp,c87468732.tpfilter,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果包含破坏所选卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 放置到灵摆区域效果的执行函数
function c87468732.tpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡片是否仍与效果相关，并将其破坏，若破坏成功则继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查自己的灵摆区域是否还有空位，若没有则结束处理
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		if c:IsRelateToEffect(e) then
			-- 将这张卡自身移动并表侧表示放置到自己的灵摆区域
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
