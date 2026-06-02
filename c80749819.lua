--Call of the Forgotten
-- 效果：
-- 这张卡发动时：可以从自己的卡组·墓地把最多3张「活死人的呼声」在自己场上盖放，直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
-- 1回合1次，自己把「活死人的呼声」发动的场合：可以以对方场上1只怪兽为对象；那只怪兽送去墓地。
-- 「怨念的呼声」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数并添加相关卡片密码列表
function s.initial_effect(c)
	-- 记录该卡记载了「活死人的呼声」的卡片密码
	aux.AddCodeList(c,97077563)
	-- 这张卡发动时：可以从自己的卡组·墓地把最多3张「活死人的呼声」在自己场上盖放，直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 1回合1次，自己把「活死人的呼声」发动的场合：可以以对方场上1只怪兽为对象；那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤自己卡组或墓地中满足盖放条件的「活死人的呼声」
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- 盖放及附加特殊召唤限制誓约的卡片发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组和墓地中获取所有不受墓地影响且可以盖放的「活死人的呼声」卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 获取自己魔陷区可用的空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 判定是否满足盖放条件并询问玩家是否进行盖放
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and ft>0 then  --"是否把卡盖放？"
		local ct=math.min(3,ft)
		-- 给玩家发送选择要盖放卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,ct,nil)
		-- 在自己场上盖放所选的卡片
		Duel.SSet(tp,sg)
		-- 直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「怨念的呼声」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.slim)
		-- 为发动卡片的玩家注册禁止特殊召唤的全局规则限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤限制的条件判定：限制从非墓地特殊召唤非不死族怪兽
function s.slim(e,c,sp,st,spos,tp,se)
	return not c:IsLocation(LOCATION_GRAVE) and not c:IsRace(RACE_ZOMBIE)
end
-- 判定是否是自己发动了「活死人的呼声」的卡片或效果
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(97077563) and rp==tp
end
-- 送墓效果的靶子判定与效果对象选择
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判定对方场上是否有能够送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择送去墓地卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为送墓效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为将目标送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 将对方场上所选的对象怪兽送去墓地的实际处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 因卡片效果将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
