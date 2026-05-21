--フューチャー・ヴィジョン
-- 效果：
-- 只要这张卡在场上存在，自己或者对方对怪兽的召唤成功时，选择那1只怪兽从游戏中除外。从召唤的怪兽的控制者来看的下次的自己的准备阶段时，这个效果除外的怪兽表侧攻击表示回到场上。
function c87902575.initial_effect(c)
	-- 只要这张卡在场上存在
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c87902575.clear)
	c:RegisterEffect(e1)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e1:SetLabelObject(ng)
	-- 自己或者对方对怪兽的召唤成功时，选择那1只怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87902575,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c87902575.rmtg)
	e2:SetOperation(c87902575.rmop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 从召唤的怪兽的控制者来看的下次的自己的准备阶段时，这个效果除外的怪兽表侧攻击表示回到场上。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87902575,1))  --"返回场上"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c87902575.retcon)
	e3:SetOperation(c87902575.retop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	-- 这个效果除外的怪兽表侧攻击表示回到场上。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCountLimit(1)
	e4:SetOperation(c87902575.clearop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
-- 卡片发动时的效果处理：清空用于记录被此卡暂时除外的怪兽的卡片组
function c87902575.clear(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():Clear()
end
-- 召唤成功时除外效果的靶向/发动准备：确认召唤的怪兽是否在场且能成为效果对象
function c87902575.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:GetFirst():IsOnField()
		and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 将召唤成功的怪兽设为效果处理的对象
	Duel.SetTargetCard(eg:GetFirst())
	-- 设置连锁信息：操作分类为除外，操作对象为召唤成功的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
-- 召唤成功时除外效果的处理：将目标怪兽暂时除外，并建立与此卡的联系，加入记录组中
function c87902575.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 若目标怪兽仍在该效果的连锁中且在怪兽区存在，则将其表侧表示暂时除外
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:CreateRelation(e:GetHandler(),RESET_EVENT+RESETS_STANDARD)
		e:GetLabelObject():GetLabelObject():AddCard(tc)
	end
end
-- 过滤函数：筛选出与此卡仍有关联，且原本控制者为指定玩家的怪兽
function c87902575.retfilter(c,ec,tp)
	return c:IsRelateToCard(ec) and c:IsPreviousControler(tp)
end
-- 准备阶段回到场上效果的发动条件：记录组中存在属于当前回合玩家（即召唤的怪兽的控制者）的被除外怪兽
function c87902575.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	-- 判断记录组中属于当前回合玩家的被除外怪兽数量是否大于0
	return g:FilterCount(c87902575.retfilter,nil,e:GetHandler(),Duel.GetTurnPlayer())>0
end
-- 准备阶段回到场上效果的处理：将属于当前回合玩家的被除外怪兽表侧攻击表示返回场上，若格子不足则由该玩家选择部分送去墓地
function c87902575.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家（即召唤的怪兽的控制者）
	local p=Duel.GetTurnPlayer()
	local lg=e:GetLabelObject():GetLabelObject()
	local g=lg:Filter(c87902575.retfilter,nil,e:GetHandler(),p)
	lg:Sub(g)
	-- 获取当前回合玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if g:GetCount()>ft then
		local sg=g
		-- 向当前回合玩家发送提示信息：请选择要回到场上的卡
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(87902575,2))  --"请选择要回到场上的卡"
		g=g:Select(p,ft,ft,nil)
		sg:Sub(g)
		-- 因场地不足无法返回场上的其余怪兽通过效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将怪兽以表侧攻击表示返回场上
		Duel.ReturnToField(tc,POS_FACEUP_ATTACK)
		tc=g:GetNext()
	end
end
-- 过滤函数：筛选出已失去与此卡关联，或者原本控制者为指定玩家的怪兽（用于清理已处理或失效的记录）
function c87902575.clfilter(c,ec,tp)
	return (not c:IsRelateToCard(ec)) or c:IsPreviousControler(tp)
end
-- 主要阶段1开始时的清理操作：从记录组中移除已失效或当前回合玩家已处理完毕的怪兽
function c87902575.clearop(e,tp,eg,ep,ev,re,r,rp)
	-- 从记录组中移除不与此卡关联或属于当前回合玩家的怪兽卡
	e:GetLabelObject():GetLabelObject():Remove(c87902575.clfilter,nil,e:GetHandler(),Duel.GetTurnPlayer())
end
