--次元障壁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个怪兽的种类（仪式·融合·同调·超量·灵摆）才能发动。这个回合中，以下效果适用。
-- ●双方不能把宣言的种类的怪兽特殊召唤，场上的宣言种类的怪兽的效果无效化。
local s,id,o=GetID()
-- 注册卡片发动时的效果（自由时点激活，有同名卡一回合一次的发动限制）。
function c83326048.initial_effect(c)
	-- ①：宣言1个怪兽的种类（仪式·融合·同调·超量·灵摆）才能发动。这个回合中，以下效果适用。●双方不能把宣言的种类的怪兽特殊召唤，场上的宣言种类的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,83326048+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c83326048.target)
	e1:SetOperation(c83326048.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择阶段，让玩家宣言（选择）一个怪兽种类，并将其作为效果参数保存。
function c83326048.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择卡片种类。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	local types={1057,1056,1063,1073,1074}
	-- 获取当前回合该玩家已经宣言过的怪兽种类的标记值（用于过滤已选择的选项）。
	local alist=Duel.GetFlagEffectLabel(tp,id)
	if not alist then
		-- 若本回合未宣言过任何种类，则让玩家从所有种类中选择一个，并将选择的种类作为效果参数保存。
		Duel.SetTargetParam(types[Duel.SelectOption(tp,table.unpack(types))+1])
	else
		local options={}
		for i = 1, 5, 1 do
			if bit.extract(alist,i)==0 then
				table.insert(options,types[i])
			end
		end
		-- 若本回合已宣言过种类，则让玩家从剩余未宣言的种类中选择一个，并将选择的种类作为效果参数保存。
		Duel.SetTargetParam(options[Duel.SelectOption(tp,table.unpack(options))+1])
	end
end
-- 效果处理阶段，获取宣言的怪兽种类，更新玩家的宣言标记，并注册“不能特殊召唤该种类怪兽”和“场上该种类怪兽效果无效化”的全局效果。
function c83326048.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段宣言的怪兽种类参数。
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ct,p=0,0
	if opt==1057 then ct=TYPE_RITUAL   p=1 end
	if opt==1056 then ct=TYPE_FUSION   p=2 end
	if opt==1063 then ct=TYPE_SYNCHRO  p=3 end
	if opt==1073 then ct=TYPE_XYZ      p=4 end
	if opt==1074 then ct=TYPE_PENDULUM p=5 end
	-- 获取当前回合该玩家已宣言过的种类标记。
	local alist=Duel.GetFlagEffectLabel(tp,id)
	if not alist then
		alist=1<<p
		-- 若本回合首次宣言，则为玩家注册一个持续到回合结束的标记效果，并记录本次宣言的种类。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,alist)
	else
		alist=alist|(1<<p)
		-- 若本回合非首次宣言，则更新玩家标记效果的Label值，追加记录本次宣言的种类。
		Duel.SetFlagEffectLabel(tp,id,alist)
	end
	-- ●双方不能把宣言的种类的怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabel(ct)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c83326048.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制双方特殊召唤宣言种类怪兽的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 场上的宣言种类的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c83326048.distg)
	e2:SetLabel(ct)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使场上宣言种类的怪兽效果无效化的全局效果。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出原本卡片种类包含所宣言种类的怪兽，用于限制特殊召唤。
function c83326048.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&e:GetLabel()>0
end
-- 过滤出场上卡片种类包含所宣言种类的怪兽，用于无效其效果。
function c83326048.distg(e,c)
	return c:IsType(e:GetLabel())
end
