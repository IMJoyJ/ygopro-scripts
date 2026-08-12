--お代狸様の代算様
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ②：只要这张卡在怪兽区域存在，自己把怪兽仪式召唤的场合，自己的额外卡组1只怪兽也能作为解放的代替而送去墓地。
local s,id,o=GetID()
-- 注册两个永续效果，分别使该卡不能被解放用于上级召唤和非上级召唤
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
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
	-- 判断是否为首次加载该脚本，避免重复定义函数
	if not aux.rit_mat_hack_check then
		-- 标记该脚本已加载，防止重复初始化
		aux.rit_mat_hack_check=true
		-- 定义一个过滤函数，用于筛选具有额外仪式素材效果且位于额外卡组的卡片
		function aux.rit_mat_hack_exmat_filter(tc)
			return tc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL,tc:GetControler()) and tc:IsLocation(LOCATION_EXTRA)
		end
		-- 定义一个函数，用于检查是否存在满足等级总和大于等于指定值的仪式素材组合
		function aux.RitualCheckGreater(g,rc,lv)
			-- 若选中的素材中包含超过1张额外卡组的仪式素材，则判定不合法
			if g:FilterCount(aux.rit_mat_hack_exmat_filter,nil)>1 then return false end
			-- 设置当前选中的卡片组，供后续等级判定使用
			Duel.SetSelectedCard(g)
			return g:CheckWithSumGreater(Card.GetRitualLevel,lv,rc)
		end
		-- 定义一个函数，用于检查是否存在满足等级总和等于指定值的仪式素材组合
		function aux.RitualCheckEqual(g,rc,lv)
			-- 若选中的素材中包含超过1张额外卡组的仪式素材，则判定不合法
			if g:FilterCount(aux.rit_mat_hack_exmat_filter,nil)>1 then return false end
			return g:CheckWithSumEqual(Card.GetRitualLevel,lv,#g,#g,rc)
		end
		-- 保存原版Duel.ReleaseRitualMaterial函数，用于后续调用
		_ReleaseRitualMaterial=Duel.ReleaseRitualMaterial
		-- 重写Duel.ReleaseRitualMaterial函数，用于处理额外卡组作为仪式素材时的计数限制
		function Duel.ReleaseRitualMaterial(mat)
			-- 从选中的卡片组中筛选出具有额外仪式素材效果的卡片
			local tc=mat:Filter(aux.rit_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			return _ReleaseRitualMaterial(mat)
		end
	end
end
