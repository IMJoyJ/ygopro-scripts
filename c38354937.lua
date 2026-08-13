--レアル・ジェネクス・クロキシアン
-- 效果：
-- 「次世代」调整＋调整以外的暗属性怪兽1只以上
-- ①：这张卡同调召唤的场合发动。得到对方场上1只等级最高的怪兽的控制权。
function c38354937.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为「次世代」字段怪兽，调整以外的素材为暗属性怪兽1只以上，合计至少1只（即调整1只＋调整以外暗属性怪兽1只以上）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- 对应①效果：这张卡同调召唤成功的场合发动，得到对方场上1只等级最高的怪兽的控制权。此处创建并注册一个诱发必发效果，在特殊召唤成功时触发，处理时获得控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38354937,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c38354937.ctcon)
	e1:SetOperation(c38354937.ctop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是以同调召唤方式特殊召唤成功（召唤类型为同调召唤）时才满足条件。
function c38354937.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：选取对方场上表侧表示且等级大于0的怪兽（因为等级0的怪兽不参与“最高等级”比较）。
function c38354937.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果处理：从对方场上所有表侧表示且等级>0的怪兽中选出等级最高的一组；若存在并列最高则让发动者选择其中1只；最后获得该怪兽的控制权。
function c38354937.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上满足过滤条件的全部怪兽（表侧表示且等级>0），作为取得控制权的候选集合。
	local g=Duel.GetMatchingGroup(c38354937.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local sg=g:GetMaxGroup(Card.GetLevel)
	if sg:GetCount()>1 then
		-- 当最高等级的怪兽不止1只时，弹出选择提示，让发动者选择其中1只要改变控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		sg=sg:Select(tp,1,1,nil)
	end
	local tc=sg:GetFirst()
	-- 将选中的怪兽控制权转移给效果发动者（tp），即“得到对方场上1只等级最高的怪兽的控制权”。
	Duel.GetControl(tc,tp)
end
