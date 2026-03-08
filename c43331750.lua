--融合複製
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或对方的墓地1张「融合」通常·速攻魔法卡为对象才能发动。那张魔法卡除外。那之后，那张魔法卡发动时的效果适用。
local s,id,o=GetID()
-- 创建并注册融合复制的发动效果，设置为自由时点、只能发动一次、需要选择对象、具有除外类别
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选墓地中的融合魔法卡（通常或速攻），且可发动效果
function s.filter(c)
	return (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSetCard(0x46) and c:IsAbleToRemove()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 处理效果的发动目标选择，设置提示信息并选择目标卡，获取其发动效果并设置当前效果属性
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	-- 检查是否满足发动条件，即场上是否存在符合条件的墓地魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的墓地魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
	-- 设置当前连锁的操作信息，指定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果发动后的实际操作，将目标卡除外并触发其发动时的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的目标卡
	local tc=Duel.GetFirstTarget()
	local te=e:GetLabelObject()
	-- 判断目标卡是否有效且成功除外
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_REMOVED) and te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
