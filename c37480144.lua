--アスポート
-- 效果：
-- ①：以自己的主要怪兽区域1只怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c37480144.initial_effect(c)
	-- 效果原文内容：①：以自己的主要怪兽区域1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c37480144.target)
	e1:SetOperation(c37480144.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤位于主要怪兽区域（序号小于5）的怪兽
function c37480144.filter(c)
	return c:GetSequence()<5
end
-- 效果作用：设置效果目标为己方主要怪兽区域的怪兽
function c37480144.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37480144.filter(chkc) end
	-- 效果作用：检查是否己方主要怪兽区域存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c37480144.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查己方主要怪兽区域是否有可用位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 效果作用：向玩家提示选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37480144,0))  --"请选择要移动位置的怪兽"
	-- 效果作用：选择目标怪兽
	Duel.SelectTarget(tp,c37480144.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果作用：处理效果发动后的操作
function c37480144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 效果作用：检查目标怪兽是否仍然在场且为己方控制
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<1 then return end
	-- 效果作用：向玩家提示选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 效果作用：选择一个可用的怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 效果作用：将目标怪兽移动到指定区域
	Duel.MoveSequence(tc,nseq)
end
