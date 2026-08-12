--Recette de Poisson～魚料理のレシピ～
-- 效果：
-- 「新式魔厨」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。这个效果把「新式魔厨的马赛鱼汤布耶尔」仪式召唤的场合，可以再让以下效果适用。
-- ●从自己的卡组·墓地把「鱼料理的食谱」以外的1张「食谱」仪式魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册卡片效果，记录关联卡号，并为仪式召唤效果追加检索、加入手卡及墓地操作的分类属性。
function s.initial_effect(c)
	-- 记录本卡记载了「新式魔厨的马赛鱼汤布耶尔」（卡号26223582）的卡名。
	aux.AddCodeList(c,26223582)
	-- 注册仪式召唤效果：从手卡仪式召唤「新式魔厨」仪式怪兽，解放等级合计在仪式怪兽以上的怪兽，并设置追加效果处理。
	local e1=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true,s.extraop)
	e1:SetCategory(e1:GetCategory()|(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION))
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选属于「新式魔厨」（0x196）系列的怪兽。
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- 过滤条件：筛选属于「食谱」（0x197）系列、可加入手卡、非同名且为仪式魔法的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToHand() and not c:IsCode(id) and c:GetType()&0x82==0x82
end
-- 追加效果处理：若仪式召唤的怪兽是「新式魔厨的马赛鱼汤布耶尔」，则可选择从卡组或墓地将1张同名卡以外的「食谱」仪式魔法卡加入手卡。
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc or not tc:IsCode(26223582) then return end
	-- 获取自己卡组及墓地中满足检索条件且不受「王家之谷」影响的卡片组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若存在符合条件的卡，则询问玩家是否适用追加效果。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把「食谱」仪式魔法卡加入手卡？"
		-- 中断当前效果，使后续的加入手卡处理与仪式召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片通过效果加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
