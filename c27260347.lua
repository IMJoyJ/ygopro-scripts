--蛇眼の大炎魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽和这张卡各当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，以「蛇眼大炎魔」以外的自己墓地1只炎属性怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置，这张卡特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果的发动条件和处理
function s.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置到魔法与陷阱区域"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mvcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的场合，以「蛇眼大炎魔」以外的自己墓地1只炎属性怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.mvcon2)
	e2:SetTarget(s.mvtg2)
	e2:SetOperation(s.mvop2)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的发动条件，即是否在攻击宣言时且对方怪兽存在且双方魔法区域有足够空间
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	local ft1=0
	local ft2=0
	if c:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	if ac and ac:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	-- 判断攻击怪兽是否为对方控制，且自己魔法区域有足够空间
	return ac and ac:IsControler(1-tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft1
		-- 判断攻击怪兽是否为对方控制，且对方魔法区域有足够空间
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>=ft2
end
-- 设置①效果的目标为攻击怪兽
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	if chk==0 then return ac~=nil end
	-- 设置连锁对象为攻击怪兽
	Duel.SetTargetCard(ac)
end
-- 处理①效果的发动，判断目标是否有效且双方魔法区域是否有足够空间
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁对象（攻击怪兽）
	local ac=Duel.GetFirstTarget()
	if not ac:IsRelateToEffect(e) or not c:IsRelateToEffect(e) or ac:IsStatus(STATUS_BATTLE_DESTROYED) or c:IsStatus(STATUS_BATTLE_DESTROYED) or not ac:IsControler(1-tp) then return false end
	local ft1=0
	local ft2=0
	if c:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	if ac and ac:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	-- 判断自己魔法区域是否有足够空间
	if not (Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft1)
		-- 判断对方魔法区域是否有足够空间
		or not (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>=ft2) then return false end
	if not ac:IsControler(1-tp) then return false end
	if ac:IsType(TYPE_MONSTER) and not ac:IsImmuneToEffect(e)
		-- 将攻击怪兽移动到魔法区域并改变其类型为魔法卡
		and Duel.MoveToField(ac,tp,ac:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 将攻击怪兽改变为魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		ac:RegisterEffect(e1)
	end
	if not c:IsImmuneToEffect(e)
		-- 将自身移动到魔法区域并改变其类型为魔法卡
		and Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 将自身改变为魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 判断②效果是否满足发动条件，即自身是否为魔法卡类型
function s.mvcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
-- 定义②效果的目标筛选函数，筛选墓地中的炎属性怪兽
function s.filter2(c,tp)
	return not c:IsCode(id) and c:IsAttribute(ATTRIBUTE_FIRE)
		-- 判断目标怪兽是否满足墓地条件且自己魔法区域有空间
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
-- 设置②效果的发动条件，即是否满足选择目标、召唤空间和自身可特殊召唤
function s.mvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter2(chkc,tp) end
	-- 判断是否满足②效果的发动条件，即是否满足选择目标
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 判断是否满足②效果的发动条件，即自己怪兽区域有召唤空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，记录目标怪兽离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息，记录自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动，将目标怪兽移动到魔法区域并改变其类型为魔法卡，然后将自身特殊召唤
function s.mvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁对象（目标怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将目标怪兽移动到魔法区域并改变其类型为魔法卡
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 将目标怪兽改变为魔法卡类型
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			-- 将自身特殊召唤到场上
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
