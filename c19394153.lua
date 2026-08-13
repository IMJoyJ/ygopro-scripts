--フェザー・ショット
-- 效果：
-- 选择自己场上表侧表示存在的1只「元素英雄 羽翼侠」发动。这个回合，选择的卡可以进行和自己场上的怪兽同样数目的攻击。那个场合，不能直接攻击对方玩家，其它的自己怪兽不能攻击。
function c19394153.initial_effect(c)
	-- 向本卡注册“元素英雄”系列字段（0x3008），使效果文本中与「元素英雄」相关的系列判定能识别本卡。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 选择自己场上表侧表示存在的1只「元素英雄 羽翼侠」发动。这个回合，选择的卡可以进行和自己场上的怪兽同样数目的攻击。那个场合，不能直接攻击对方玩家，其它的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c19394153.condition)
	e1:SetTarget(c19394153.target)
	e1:SetOperation(c19394153.operation)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件：回合玩家当前能够进入战斗阶段时才允许发动。
function c19394153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前能否进入战斗阶段”的判定结果，作为发动条件是否成立的依据。
	return Duel.IsAbleToEnterBP()
end
-- 过滤函数：筛选出自己场上表侧表示且卡名为「元素英雄 羽翼侠」（卡号21844576）的怪兽，作为可选对象。
function c19394153.filter(c)
	return c:IsFaceup() and c:IsCode(21844576)
end
-- 取对象阶段：检查并选择1只符合条件的「元素英雄 羽翼侠」，同时预先给己方全场怪兽施加“不能攻击”的誓约效果，并用标签记录被选中怪兽以将其排除；该限制持续到回合结束。
function c19394153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19394153.filter(chkc) end
	-- 在发动合法性检查时，确认自己场上是否存在至少1只符合条件的「元素英雄 羽翼侠」可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c19394153.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上表侧表示的怪兽中选取1只「元素英雄 羽翼侠」作为效果对象，并登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c19394153.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 这个回合，选择的卡可以进行和自己场上的怪兽同样数目的攻击。那个场合，不能直接攻击对方玩家，其它的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c19394153.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“其他自己怪兽不能攻击”的誓约效果实际注册到场上（己方怪兽区），使其在本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理：若对象仍与效果关联，则根据自己场上怪兽数量，为对象追加“额外攻击次数=场上怪兽数-1”，并使其本回合不能直接攻击。
function c19394153.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的「元素英雄 羽翼侠」作为要处理的对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 统计自己场上怪兽区的怪兽数量，用于计算可攻击次数（额外攻击次数需减1）。
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		if ct>1 then
			-- 这个回合，选择的卡可以进行和自己场上的怪兽同样数目的攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(ct-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那个场合，不能直接攻击对方玩家。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 设置“不能攻击”效果的排除条件：通过FieldID比对，使被选中的「元素英雄 羽翼侠」自身不受限制，只有其他自己怪兽不能攻击。
function c19394153.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
