--水精鱗－アビスマンダー
-- 效果：
-- 可以把墓地的这张卡从游戏中除外，从以下效果选择1个发动。
-- ●自己场上的全部名字带有「水精鳞」的怪兽的等级上升1星。
-- ●自己场上的全部名字带有「水精鳞」的怪兽的等级上升2星。
function c21767650.initial_effect(c)
	-- 可以把墓地的这张卡从游戏中除外，从以下效果选择1个发动。●自己场上的全部名字带有「水精鳞」的怪兽的等级上升1星。●自己场上的全部名字带有「水精鳞」的怪兽的等级上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21767650,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动效果所需的代价：将墓地的这张卡从游戏中除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c21767650.lvtg)
	e1:SetOperation(c21767650.lvop)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且卡名含有「水精鳞」字段的怪兽（用于选取我方场上的对象）。
function c21767650.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74) and c:IsLevelAbove(0)
end
-- 发动时的目标处理：确认我方场上有满足条件的水精鳞怪兽；若可以发动，则让玩家从“上升1星”和“上升2星”中选择一项，并把选择结果存入效果标签。
function c21767650.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：我方场上是否存在至少1只符合筛选条件的表侧表示水精鳞怪兽（作为效果发动的前提）。
	if chk==0 then return Duel.IsExistingMatchingCard(c21767650.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 让发动玩家在“等级全部上升1星”和“等级全部上升2星”两个选项中选择1个，选项序号保存到效果标签，供处理时使用。
	local opt=Duel.SelectOption(tp,aux.Stringid(21767650,1),aux.Stringid(21767650,2))  --"等级全部上升1星/等级全部上升2星"
	e:SetLabel(opt)
end
-- 效果处理：读取玩家选择的星数，获取我方场上的全部水精鳞怪兽，并分别对这些怪兽赋予对应的等级上升效果，持续到怪兽离场或触发标准重置。
function c21767650.lvop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	-- 获取我方场上所有符合条件的水精鳞怪兽（不取对象，在实际处理时选择目标）。
	local g=Duel.GetMatchingGroup(c21767650.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- ●自己场上的全部名字带有「水精鳞」的怪兽的等级上升1星。●自己场上的全部名字带有「水精鳞」的怪兽的等级上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
