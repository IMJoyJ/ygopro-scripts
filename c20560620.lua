--お代狸様の代算様
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ②：只要这张卡在怪兽区域存在，自己把怪兽仪式召唤的场合，自己的额外卡组1只怪兽也能作为解放的代替而送去墓地。
local s,id,o=GetID()
-- 此函数注册代狸大人的全部效果：①使自身不能解放（同时禁止上级召唤与其它方式的解放）；②作为场上永续效果，允许自己在仪式召唤时从额外卡组选择1只怪兽代替解放；并安装全局补丁以支持额外卡组怪兽作为仪式素材的判定与解放处理。
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。（此处对应不能作为上级召唤的解放，后续e2补充禁止其它解放。）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己把怪兽仪式召唤的场合，自己的额外卡组1只怪兽也能作为解放的代替而送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 检查是否已经安装过仪式素材辅助补丁，避免重复覆盖全局函数。
	if not aux.rit_mat_hack_check then
		-- 将补丁标记设为true，表示已执行过后续的全局函数覆盖操作。
		aux.rit_mat_hack_check=true
		-- 定义过滤函数：筛选出拥有“可作为额外卡组仪式素材”效果且当前位于额外卡组的卡。
		function aux.rit_mat_hack_exmat_filter(tc)
			return tc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL,tc:GetControler()) and tc:IsLocation(LOCATION_EXTRA)
		end
		-- 覆盖aux.RitualCheckGreater，用于仪式召唤检查素材等级总和是否大于等于目标等级，并加入额外卡组素材数量限制。
		function aux.RitualCheckGreater(g,rc,lv)
			-- 如果素材组中来自额外卡组的可代替素材数量超过1只，则不满足“1只怪兽作为代替”的限制，返回false。
			if g:FilterCount(aux.rit_mat_hack_exmat_filter,nil)>1 then return false end
			-- 将当前选中的素材组设置为已选择卡片，使CheckWithSumGreater能正确计算这些卡的仪式等级。
			Duel.SetSelectedCard(g)
			return g:CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
		end
		-- 覆盖aux.RitualCheckEqual，用于仪式召唤检查素材等级总和是否刚好等于目标等级，同样限制额外卡组素材数量。
		function aux.RitualCheckEqual(g,rc,lv)
			-- 如果素材组中来自额外卡组的可代替素材数量超过1只，则不满足“1只怪兽作为代替”的限制，返回false。
			if g:FilterCount(aux.rit_mat_hack_exmat_filter,nil)>1 then return false end
			return g:CheckWithSumEqual(Card.GetRitualLevel,lv,#g,#g,rc)
		end
		-- 保存原始的Duel.ReleaseRitualMaterial函数，便于在包装函数中调用原有解放逻辑。
		_ReleaseRitualMaterial=Duel.ReleaseRitualMaterial
		-- 包装Duel.ReleaseRitualMaterial：在正式处理仪式素材解放前，先处理额外卡组素材的次数消耗，再执行原解放流程。
		function Duel.ReleaseRitualMaterial(mat)
			-- 从要解放的素材组中取出第一个满足额外卡组素材条件的卡；若没有则为nil，后续不进行额外处理。
			local tc=mat:Filter(aux.rit_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			return _ReleaseRitualMaterial(mat)
		end
	end
end
