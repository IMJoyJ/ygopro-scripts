--戦華の雄－張徳
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「战华」怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力在自己回合内上升对方场上的怪兽数量×300。
-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c2801664.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上有「战华」怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2801664,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2801664)
	e1:SetCondition(c2801664.spcon)
	e1:SetTarget(c2801664.sptg)
	e1:SetOperation(c2801664.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力在自己回合内上升对方场上的怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2801664.atkcon)
	e2:SetValue(c2801664.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2801664,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2801665)
	e3:SetCondition(c2801664.xatkcon)
	e3:SetTarget(c2801664.xatktg)
	e3:SetOperation(c2801664.xatkop)
	c:RegisterEffect(e3)
end
-- 定义筛选条件：卡须为表侧表示且属于「战华」系列（字段0x137），用于找出场上符合条件的「战华」怪兽。
function c2801664.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果①的发动条件：检查自己场上是否存在至少2只满足cfilter的表侧表示「战华」怪兽；是则条件成立，否则不能发动。
function c2801664.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己主要怪兽区检索是否存在至少2只表侧表示且字段为「战华」的怪兽，返回布尔值作为①的发动条件。
	return Duel.IsExistingMatchingCard(c2801664.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果①发动时的目标合法性检测：确认自己场上有空余的怪兽区域，且这张卡自身可以被特殊召唤；只有两者都满足时效果才能发动。
function c2801664.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己场上是否有可用的怪兽区域（空格数>0），这是特殊召唤的前提条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：本次操作会将这张卡作为特殊召唤对象（数量1）置入处理，用于后续效果检索或判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时的操作：确认这张卡仍与效果关联后，将其从手卡特殊召唤到场上；若已不关联则不处理。
function c2801664.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其控制者的场上，不改变控制权，表示形式为表侧表示。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的适用条件：只在当前回合玩家是这张卡的控制者时（即自己回合内）攻击力上升效果才适用。
function c2801664.atkcon(e)
	-- 判断当前回合玩家是否等于这张卡的控制者，用于确定是否处于“自己回合”。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- ②效果的数值计算：取得对方场上怪兽的数量，乘以300，作为这张卡的攻击力上升数值。
function c2801664.atkval(e,c)
	-- 计算对方场上怪兽数量×300，返回攻击力上升值。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)*300
end
-- 效果③的发动条件：对方场上的怪兽数量多于自己场上的怪兽数量，并且当前可以进入战斗阶段；两者同时满足才可发动。
function c2801664.xatkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方与自己场上的怪兽数量，若对方怪兽数量大于己方怪兽数量，则条件成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
		-- 追加条件：当前回合玩家能够进入战斗阶段，确保该效果可以在合适的时点发动。
		and Duel.IsAbleToEnterBP()
end
-- 效果③发动时的目标检测：确认这张卡当前没有已适用的“可以对怪兽追加攻击”效果（EFFECT_EXTRA_ATTACK_MONSTER），避免重复赋予额外攻击次数。
function c2801664.xatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) end
end
-- 效果③处理：若这张卡仍与效果关联，则给它附加一个“战斗阶段中可以追加攻击1次”的效果，使其最多能攻击怪兽2次；该效果不会被无效，并持续到回合结束阶段。
function c2801664.xatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
