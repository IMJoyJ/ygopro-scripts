--はぐれ者傭兵部隊
-- 效果：
-- 自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。选择对方场上1只怪兽直到结束阶段时得到控制权。这个效果发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。
function c12836042.initial_effect(c)
	-- “自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。选择对方场上1只怪兽直到结束阶段时得到控制权。这个效果发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12836042,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12836042.condition)
	e1:SetCost(c12836042.cost)
	e1:SetTarget(c12836042.target)
	e1:SetOperation(c12836042.operation)
	c:RegisterEffect(e1)
end
-- 发动条件函数：判定自己场上是否不存在这张卡以外的怪兽（即自己场上怪兽数量不超过1）。
function c12836042.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上主要怪兽区的卡数，若小于等于1则满足“自己场上没有这张卡以外的怪兽存在”的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 发动代价函数：确认是否满足发动条件，并实际支付解放此卡、附加本回合不能特殊召唤且不能进入战斗阶段的誓约限制。
function c12836042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：本回合自己尚未进行过战斗阶段，因为发动后不能进入战斗阶段。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
		-- 代价合法性检查：本回合自己尚未特殊召唤过怪兽，因为发动后不能特殊召唤怪兽。
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		and e:GetHandler():IsReleasable() end
	-- “选择对方场上1只怪兽直到结束阶段时得到控制权。这个效果发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤”的效果作为誓约效果注册给自己，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BP)
	-- 将“不能进入战斗阶段”的效果作为誓约效果注册给自己，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
	-- 解放发动效果的这张卡作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标选择函数：选择对方场上1只可以被改变控制权的怪兽，并确认自己场上有可用的怪兽区来承接控制权。
function c12836042.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 目标合法性检查：这张卡离开自己场上后，自己场上仍有空余的怪兽区，才能放置获得控制权的怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 继续检查：对方场上存在至少1只可以改变控制权且能成为效果对象的怪兽。
		and Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,true) end
	-- 给玩家显示选择提示消息，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足改变控制权条件的怪兽作为对象，并自动建立与当前连锁的关联。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果将改变1只怪兽的控制权，供连锁检测与效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数：获得作为对象的怪兽的控制权，持续到结束阶段，并确认对象仍与效果关联。
function c12836042.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中记录的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给自己，直到结束阶段时重置控制权。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
