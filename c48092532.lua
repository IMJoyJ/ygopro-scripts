--異次元の生還者
-- 效果：
-- 自己场上表侧表示存在的这张卡从游戏中除外的场合，这张卡在结束阶段时特殊召唤到场上。
function c48092532.initial_effect(c)
	-- 对应效果原文“自己场上表侧表示存在的这张卡从游戏中除外的场合”：创建并注册一个持续效果，在该卡被除外时进行条件判定并记录标记。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c48092532.rmcon)
	e1:SetOperation(c48092532.rmop)
	c:RegisterEffect(e1)
	-- 对应效果原文“这张卡在结束阶段时特殊召唤到场上”：创建并注册一个在结束阶段触发的必发效果，若之前已被除外且在除外区，则将自身特殊召唤上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48092532,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c48092532.condition)
	e2:SetTarget(c48092532.target)
	e2:SetOperation(c48092532.operation)
	c:RegisterEffect(e2)
end
-- 除外事件的触发条件：判断被除外的这张卡在离开场上之前是自己的表侧表示怪兽，且控制者为该效果的使用者tp。
function c48092532.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 除外事件处理：给自身注册一个标记（编号48092532），表示这张卡本回合曾被除外；该标记在标准重置事件或结束阶段时会被重置。
function c48092532.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(48092532,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的发动条件：检查该卡是否带有“本回合曾被除外”的标记（编号48092532），有标记才允许发动结束阶段的特殊召唤效果。
function c48092532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(48092532)~=0
end
-- 特殊召唤效果的发动目标处理：在发动检查阶段确认本回合尚未发动过此效果（编号48092533的标记为0）；发动确定后登记操作信息，并注册标记48092533防止同一张卡在结束阶段重复发动。
function c48092532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(48092533)==0 end
	-- 设置当前连锁的操作信息，声明本效果将进行特殊召唤，处理对象为该效果处理的这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(48092533,RESET_EVENT+0x4760000+RESET_PHASE+PHASE_END,0,1)
end
-- 效果处理阶段：若这张卡仍与效果关联，则尝试将其特殊召唤；若主要怪兽区没有空位，则改为将自身送去墓地；若有空位则表侧表示特殊召唤。
function c48092532.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 检查自己场上主要怪兽区的可用空格数是否小于等于0，即是否没有可特殊召唤的区域。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			-- 因无可用怪兽区而无法特殊召唤时，将这张卡以效果原因送去墓地。
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
			return
		end
		-- 将这张卡以表侧表示形式特殊召唤到玩家tp的场上（不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
