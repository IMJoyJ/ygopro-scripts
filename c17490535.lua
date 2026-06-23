--エーリアン・ブレイン
-- 效果：
-- 自己场上存在的爬虫类族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。得到那个时候进行攻击的对方怪兽的控制权，那只怪兽当作爬虫类族使用。
function c17490535.initial_effect(c)
	-- 创建效果，设置为发动时的效果，触发事件为战斗破坏送去墓地，条件为c17490535.condition，目标为c17490535.target，效果处理为c17490535.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c17490535.condition)
	e1:SetTarget(c17490535.target)
	e1:SetOperation(c17490535.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：被战斗破坏的怪兽是自己场上的爬虫类族怪兽，且该怪兽在破坏前的控制者是自己，且该怪兽在破坏前的种族包含爬虫类，且该怪兽是攻击目标，且该怪兽在墓地，且该怪兽是因战斗破坏
function c17490535.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return eg:GetCount()==1 and ec:IsPreviousControler(tp) and ec:IsRace(RACE_REPTILE)
		and bit.band(ec:GetPreviousRaceOnField(),RACE_REPTILE)~=0
		-- 该怪兽是攻击目标，且该怪兽在墓地，且该怪兽是因战斗破坏
		and ec==Duel.GetAttackTarget() and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_BATTLE)
end
-- 设置目标：获取导致怪兽破坏的攻击怪兽，若满足条件则设置该怪兽为效果目标，并设置操作信息为改变控制权
function c17490535.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst():GetReasonCard()
	if chk==0 then return tc:IsControler(1-tp) and tc:IsRelateToBattle() and tc:IsControlerCanBeChanged() end
	-- 设置当前连锁的效果目标为tc
	Duel.SetTargetCard(tc)
	-- 设置当前连锁的操作信息为改变控制权，目标为tc，数量为1
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 效果处理：获取当前连锁的目标怪兽，若该怪兽仍然有效，则尝试获得其控制权，若成功则赋予其爬虫类族效果
function c17490535.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试获得目标怪兽的控制权，若成功则继续执行
		if Duel.GetControl(tc,tp)~=0 then
			-- 创建一个改变种族的效果，使目标怪兽变为爬虫类族，该效果在标准重置时重置
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_REPTILE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
