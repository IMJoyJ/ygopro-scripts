--水精鱗－アビスマンダー
-- 效果：
-- 可以把墓地的这张卡从游戏中除外，从以下效果选择1个发动。
-- ●自己场上的全部名字带有「水精鳞」的怪兽的等级上升1星。
-- ●自己场上的全部名字带有「水精鳞」的怪兽的等级上升2星。
function c21767650.initial_effect(c)
	-- 效果原文内容：可以把墓地的这张卡从游戏中除外，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21767650,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c21767650.lvtg)
	e1:SetOperation(c21767650.lvop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的、卡名含「水精鳞」的怪兽
function c21767650.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74) and c:IsLevelAbove(0)
end
-- 效果处理函数，检查场上是否存在满足条件的怪兽并让玩家选择效果
function c21767650.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21767650.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 让玩家在两个效果中选择一个（等级上升1星或2星）
	local opt=Duel.SelectOption(tp,aux.Stringid(21767650,1),aux.Stringid(21767650,2))  --"等级全部上升1星/等级全部上升2星"
	e:SetLabel(opt)
end
-- 效果执行函数，为符合条件的怪兽设置等级上升效果
function c21767650.lvop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	-- 获取场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c21767650.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 效果原文内容：●自己场上的全部名字带有「水精鳞」的怪兽的等级上升1星。●自己场上的全部名字带有「水精鳞」的怪兽的等级上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
