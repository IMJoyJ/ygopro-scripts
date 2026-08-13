--ライブラの魔法秤
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：宣言1～6的任意等级，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的等级下降宣言的等级数值，另1只怪兽的等级上升宣言的等级数值。
-- 【怪兽描述】
-- 拥有意志的天秤。虽然维持着世间的平衡，却常常将锤星放错位置。
function c43857222.initial_effect(c)
	-- 给这张卡注册灵摆怪兽属性，使其获得灵摆召唤、灵摆区发动等能力。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：宣言1～6的任意等级，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的等级下降宣言的等级数值，另1只怪兽的等级上升宣言的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43857222,0))  --"改变等级"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43857222)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c43857222.lvtg)
	e1:SetOperation(c43857222.lvop)
	c:RegisterEffect(e1)
end
-- 定义筛选下降对象的候选函数：该怪兽需表侧表示且等级至少为2，同时自己场上还存在其他表侧表示怪兽可作为上升对象。
function c43857222.lvfilter1(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(2)
		-- 检查自己场上除候选怪兽外，是否存在至少1只表侧表示且等级不低于1的怪兽，可作为另一只效果对象。
		and Duel.IsExistingTarget(c43857222.lvfilter2,tp,LOCATION_MZONE,0,1,c,1)
end
-- 判断怪兽是否表侧表示且等级不低于指定数值lv；用于选择下降对象时保证其等级足够承受等级下降。
function c43857222.lvfilter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(lv)
end
-- 筛选自己场上所有表侧表示、等级不低于1且能成为当前效果对象的怪兽，作为选择对象的候选池。
function c43857222.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- 检查已选择的2只怪兽中是否存在至少1只等级不低于lv+1的怪兽，确保该怪兽在下降lv后等级不会低于1。
function c43857222.gcheck(g,lv)
	return g:IsExists(Card.IsLevelAbove,1,nil,lv+1)
end
-- 发动时的目标选择处理：合法时获取候选池、宣言1～6中不超过最高等级-1的等级，再选择2只满足条件的怪兽并设为对象，将宣言等级存入效果标签。
function c43857222.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判定：检查自己场上是否存在至少1只满足lvfilter1的怪兽，即存在一只等级至少为2且另有其他表侧怪兽可作为对象的组合；若存在则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c43857222.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取当前玩家主要怪兽区所有满足tgfilter的怪兽，构成可选择对象的候选组。
	local g=Duel.GetMatchingGroup(c43857222.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	-- 让玩家宣言1～6中的任意等级，且宣言上限取场上最高等级减1与6中的较小值，以保证有怪兽能够下降该等级。
	local alv=Duel.AnnounceLevel(tp,1,math.min(lv-1,6))
	-- 发出请选择效果对象的提示信息，引导玩家选择2只对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c43857222.gcheck,false,2,2,alv)
	-- 将选中的2只怪兽登记为当前连锁的效果对象，使它们与发动效果建立关联。
	Duel.SetTargetCard(tg)
	e:SetLabel(alv)
end
-- 效果处理时的操作：获取发动时选择的对象，若对象仍存在则选择其中1只作为下降对象，对其赋予等级下降效果；若另一只仍表侧表示，则赋予等级上升效果。
function c43857222.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关联的对象（即发动时选择的2只怪兽），若不存在任何关联对象则直接终止处理。
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要下降等级的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43857222,1))  --"请选择要下降等级的怪兽"
	local tc1=g:FilterSelect(tp,c43857222.lvfilter2,1,1,nil,lv+1):GetFirst()
	if tc1 then
		local c=e:GetHandler()
		local tc2=(g-tc1):GetFirst()
		-- 作为对象的1只怪兽的等级下降宣言的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if tc1:RegisterEffect(e1) and tc2 and tc2:IsFaceup() then
			-- 另1只怪兽的等级上升宣言的等级数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e2)
		end
	end
end
