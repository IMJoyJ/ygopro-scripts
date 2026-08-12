--魔界劇団－ビッグ・スター
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡加入手卡。
-- 【怪兽效果】
-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
-- ②：1回合1次，自己主要阶段才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。这个效果盖放的卡在结束阶段送去墓地。
function c25629622.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，允许灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25629622,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c25629622.thcost)
	e1:SetTarget(c25629622.thtg)
	e1:SetOperation(c25629622.thop)
	c:RegisterEffect(e1)
	-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c25629622.limop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_CHAIN_END)
	e0:SetOperation(c25629622.limop2)
	c:RegisterEffect(e0)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。这个效果盖放的卡在结束阶段送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c25629622.settg)
	e4:SetOperation(c25629622.setop)
	c:RegisterEffect(e4)
end
-- 检查并选择1只自己场上的「魔界剧团」怪兽进行解放作为效果的代价
function c25629622.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可解放的「魔界剧团」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x10ec) end
	-- 选择1只满足条件的「魔界剧团」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x10ec)
	-- 将选中的怪兽解放作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 定义用于检索的「魔界台本」魔法卡的过滤条件
function c25629622.thfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果的目标为己方墓地中的「魔界台本」魔法卡
function c25629622.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25629622.thfilter(chkc) end
	-- 检查己方墓地是否存在至少1张满足条件的「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c25629622.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的「魔界台本」魔法卡作为效果目标
	local g=Duel.SelectTarget(tp,c25629622.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将目标卡加入手牌
function c25629622.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 设置召唤成功时的连锁限制效果
function c25629622.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁是否为空
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制，禁止对方发动魔法或陷阱卡的效果
		Duel.SetChainLimitTillChainEnd(c25629622.chlimit)
	-- 判断当前连锁是否为1
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(25629622,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义连锁限制函数，允许自己或怪兽发动效果
function c25629622.chlimit(e,rp,tp)
	return tp==rp or e:IsActiveType(TYPE_MONSTER)
end
-- 处理连锁结束时的连锁限制效果
function c25629622.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(25629622)~=0 then
		-- 设置连锁限制，禁止对方发动魔法或陷阱卡的效果
		Duel.SetChainLimitTillChainEnd(c25629622.chlimit)
	end
	e:GetHandler():ResetFlagEffect(25629622)
end
-- 定义用于盖放的「魔界台本」魔法卡的过滤条件
function c25629622.setfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 设置盖放效果的目标为己方卡组中的「魔界台本」魔法卡
function c25629622.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1张满足条件的「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25629622.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行效果操作，从卡组选择1张「魔界台本」魔法卡盖放
function c25629622.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「魔界台本」魔法卡
	local g=Duel.SelectMatchingCard(tp,c25629622.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功盖放了卡
	if tc and Duel.SSet(tp,tc)~=0 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(25629622,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 在结束阶段将盖放的卡送去墓地
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c25629622.tgcon)
		e1:SetOperation(c25629622.tgop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册结束阶段的处理效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为当前盖放的卡
function c25629622.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(25629622)==e:GetLabel()
end
-- 将盖放的卡送去墓地
function c25629622.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将卡送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
