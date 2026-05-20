--サニー・ピクシー
-- 效果：
-- 这张卡被光属性的同调怪兽的同调召唤使用送去墓地的场合，自己回复1000基本分。
function c73837870.initial_effect(c)
	-- 这张卡被光属性的同调怪兽的同调召唤使用送去墓地的场合，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73837870,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c73837870.reccon)
	e1:SetTarget(c73837870.rectg)
	e1:SetOperation(c73837870.recop)
	c:RegisterEffect(e1)
end
-- 检查此卡是否作为同调素材送去墓地，且该同调怪兽是否为光属性
function c73837870.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 设置效果发动的目标玩家、参数以及回复操作信息
function c73837870.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行回复基本分的效果处理
function c73837870.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
