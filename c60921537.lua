--凶導の葬列
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己墓地的融合·同调怪兽除外，从自己的手卡·墓地把1只「教导」仪式怪兽仪式召唤。那之后，场上有「凶导的白骑士」以及「凶导的白圣骸」存在的场合，可以把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
function c60921537.initial_effect(c)
	-- 在卡片中注册记载的卡片密码「凶导的白骑士」与「凶导的白圣骸」，用于卡片关联检索
	aux.AddCodeList(c,40352445,48654323)
	-- 注册仪式召唤效果：从手卡·墓地仪式召唤，可用墓地的融合·同调怪兽除外代替解放，并包含后续追加效果
	local e1=aux.AddRitualProcGreater2(c,c60921537.filter,LOCATION_HAND+LOCATION_GRAVE,c60921537.grfilter,nil,true,c60921537.extraop)
	e1:SetCountLimit(1,60921537+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于筛选「教导」系列怪兽
function c60921537.filter(c)
	return c:IsSetCard(0x145)
end
-- 过滤条件：用于筛选墓地的融合怪兽或同调怪兽
function c60921537.grfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 过滤条件：用于筛选场上表侧表示的指定卡名的怪兽
function c60921537.opfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 仪式召唤成功后的追加效果：若场上存在「凶导的白骑士」和「凶导的白圣骸」，可确认自己或对方的额外卡组并将1张卡送去墓地
function c60921537.extraop(e,tp,eg,ep,ev,re,r,rp,tc)
	if not tc then return end
	-- 获取自己额外卡组的卡片组
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 获取对方额外卡组的卡片组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 检查场上是否存在表侧表示的「凶导的白骑士」
	if Duel.IsExistingMatchingCard(c60921537.opfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,40352445)
		-- 检查场上是否存在表侧表示的「凶导的白圣骸」
		and Duel.IsExistingMatchingCard(c60921537.opfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,48654323)
		-- 在双方额外卡组不为空的情况下，询问玩家是否确认额外卡组并选怪兽送去墓地
		and (#g1~=0 or #g2~=0) and Duel.SelectYesNo(tp,aux.Stringid(60921537,0)) then  --"是否确认额外卡组并选怪兽送去墓地？"
		-- 中断当前效果连接，使后续处理与仪式召唤不视为同时进行
		Duel.BreakEffect()
		local g=nil
		-- 判断是否选择确认自己的额外卡组（若对方额外卡组为空，或玩家主动选择确认自己额外卡组）
		if #g1~=0 and (#g2==0 or Duel.SelectOption(tp,aux.Stringid(60921537,1),aux.Stringid(60921537,2))==0) then  --"确认自己的额外卡组/确认对方的额外卡组"
			g=g1
		else
			g=g2
			-- 向玩家展示所选的额外卡组（通常用于确认对方的额外卡组）
			Duel.ConfirmCards(tp,g,true)
		end
		-- 在系统提示栏显示“请选择要送去墓地的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
		-- 将选中的额外卡组怪兽送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
