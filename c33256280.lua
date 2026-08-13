--メタルフォーゼ・ゴルドライバー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽描述】
-- 闪耀着黄金车身的光芒，以豪爽的漂移跑法横扫敌军。尽管经常都很夸张地出现侧滑失控，但本人坚定立场地表示那就是必杀技。
function c33256280.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性（灵摆召唤及灵摆区发动相关效果）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33256280.target)
	e1:SetOperation(c33256280.operation)
	c:RegisterEffect(e1)
end
-- 目标筛选函数：判断候选对象是否为表侧表示，且我方魔陷区有空位，且卡组中存在可盖放的「炼装」魔法·陷阱卡。
function c33256280.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 返回条件：我方魔陷区可用空格数大于0，且卡组中存在符合条件的「炼装」魔法·陷阱卡。
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c33256280.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 卡组筛选函数：找出卡名含有「炼装」字段、属于魔法/陷阱卡且当前可以盖放到魔陷区的卡。
function c33256280.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 效果发动时的目标处理：选择这张卡以外的自己场上1张表侧表示的卡作为对象，并登记破坏相关的操作信息。
function c33256280.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c33256280.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 发动时检查：确认场上是否存在满足条件的对象（自己场上表侧表示、不是这张卡本身，且满足后续破坏与盖放条件）。
	if chk==0 then return Duel.IsExistingTarget(c33256280.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张满足条件的表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,c33256280.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 登记本次连锁的破坏操作信息：将破坏所选对象1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：若这张卡和对象仍与效果关联，则破坏对象，成功后从卡组选1张「炼装」魔法·陷阱卡盖放到自己场上。
function c33256280.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认效果发动卡和对象卡仍与本次效果相关，且对象卡被效果成功破坏时才继续处理。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给玩家显示“请选择要盖放的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足条件的「炼装」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c33256280.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选择的卡盖放到自己魔法陷阱区。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
